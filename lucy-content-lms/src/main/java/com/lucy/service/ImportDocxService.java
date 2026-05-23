package com.lucy.service;

import java.io.File;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import java.sql.Types;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import com.lucy.utils.DBConnection;
import com.lucy.utils.DocxReader;

public class ImportDocxService {
    private static final Pattern KEY_VALUE_PATTERN = Pattern.compile(
            "(?i)(?<![A-Za-z])("
                    + "TemplateDurationMinutes|TemplateDescription|TemplateStepTitle|"
                    + "QuestionNumber|DifficultyLevel|QuestionType|SkillTarget|QuestionText|QueRomanization|"
                    + "PronunciationNote|GrammarNote|ExampleContext|"
                    + "AnsRomanization|AnswerOrder|AnswerText|"
                    + "LanguageName|Descriptions|DurationMinutes|SubDurationMins|StageNumber|"
                    + "CefrStart|CefrEnd|CeftStart|CeftEnd|LevelStart|LevelEnd|CompletionOutcome|"
                    + "NoteType|NoteText|ContentText|StepNumber|StepTitle|"
                    + "GroupTitle|GrCefrLevel|CefrLevel|GrLevelStart|GrLevelEnd|"
                    + "LevelDescription|LevelNumber|LevelTitle|"
                    + "SubLevelNumber|SublevelNumber|SubLevelTitle|SublevelTitle|MainTask|PromptHint|Translation"
                    + ")\\s*[:?]");

    private final DocxReader docxReader;

    public ImportDocxService() {
        this.docxReader = new DocxReader();
    }

    public void printRawContentFromFile(String importFolderPath, String targetFileName) {
        File file = new File(importFolderPath, targetFileName);
        ensureFile(file);

        System.out.println("======================================");
        System.out.println("DU LIEU THO BEN TRONG FILE:");
        System.out.println("File name: " + file.getName());
        System.out.println("======================================");

        List<String> lines = docxReader.readRawLinesByEnter(file);
        for (int i = 0; i < lines.size(); i++) {
            System.out.println((i + 1) + ": " + lines.get(i));
        }

        System.out.println("Tong so dong doc duoc: " + lines.size());
    }

    public void printRawContentFromResourceFiles(String importFolderPath) {
        for (File file : listDocxFiles(importFolderPath)) {
            printRawContentFromFile(importFolderPath, file.getName());
        }
    }

    public ParsedImportData parseDocxImportData(String importFolderPath, String targetFileName) {
        File file = new File(importFolderPath, targetFileName);
        ensureFile(file);

        ParsedImportData data = new ParsedImportData();
        data.sourceFileName = file.getName();
        data.rawLines.addAll(docxReader.readRawLinesByEnter(file));

        parseTokens(data, tokenize(data.rawLines));
        applyFileNameFallbacks(data, file.getName());
        applyContentLevelRange(data);
        createGroupsIfNeeded(data);
        assignLevelsToGroups(data);
        createDefaultSubLevelsForQuestions(data);
        applyStageDefaultsToSubLevels(data);

        return data;
    }

    public ParsedImportData parseEngStage1RawData(String importFolderPath, String targetFileName) {
        return parseDocxImportData(importFolderPath, targetFileName);
    }

    public void printParsedEngStage1RawData(String importFolderPath, String targetFileName) {
        printParsedDocxImportData(importFolderPath, targetFileName);
    }

    public void printParsedDocxImportData(String importFolderPath, String targetFileName) {
        ParsedImportData data = parseDocxImportData(importFolderPath, targetFileName);

        System.out.println("======================================");
        System.out.println("PARSED FILE: " + data.sourceFileName);
        System.out.println("LanguageName: " + data.languageName);
        System.out.println("StageNumber: " + data.stage.stageNumber);
        System.out.println("LevelStart: " + data.stage.levelStart);
        System.out.println("LevelEnd: " + data.stage.levelEnd);
        System.out.println("Notes: " + data.notes.size());
        System.out.println("Templates: " + data.stepTemplates.size());
        System.out.println("Groups: " + data.levelGroups.size());
        System.out.println("Levels: " + data.levels.size());
        for (LevelRow level : data.levels) {
            System.out.println("  Level " + level.levelNumber + " group=" + level.groupNumber + " title=" + level.levelTitle);
        }
        System.out.println("SubLevels: " + data.subLevels.size());
        System.out.println("Questions: " + data.questions.size());
        System.out.println("QuestionContents: " + data.questionContents.size());
        System.out.println("SampleAnswers: " + data.sampleAnswers.size());
    }

    public ImportSummary importEngStage1ToDatabase(String importFolderPath, String targetFileName) {
        return importDocxToDatabase(importFolderPath, targetFileName);
    }

    public ImportSummary importDocxToDatabase(String importFolderPath, String targetFileName) {
        ParsedImportData data = parseDocxImportData(importFolderPath, targetFileName);
        validateForImport(data, targetFileName);

        String languageId = buildLanguageId(data.languageName);
        String stageId = buildStageId(languageId, data.stage.stageNumber);

        try (Connection conn = DBConnection.getConnection()) {
            if (conn == null) {
                throw new IllegalStateException("Khong mo duoc ket noi database");
            }

            boolean oldAutoCommit = conn.getAutoCommit();
            conn.setAutoCommit(false);
            try {
                deleteExistingStageData(conn, stageId);
                upsertLanguage(conn, languageId, data.languageName);
                upsertStage(conn, stageId, languageId, data.stage);
                insertStageNotes(conn, stageId, data.notes);
                insertStageStepTemplates(conn, stageId, data.stepTemplates);
                insertLevelGroups(conn, stageId, data.levelGroups);
                insertLevels(conn, stageId, data.levels);
                insertSubLevels(conn, stageId, data.subLevels);
                insertQuestions(conn, stageId, data.questions);
                insertQuestionContents(conn, stageId, languageId, data.questionContents);
                insertSampleAnswers(conn, stageId, languageId, data.sampleAnswers);
                conn.commit();
            } catch (Exception e) {
                conn.rollback();
                throw e;
            } finally {
                conn.setAutoCommit(oldAutoCommit);
            }
        } catch (Exception e) {
            throw new RuntimeException("Loi import file " + targetFileName + ": " + e.getMessage(), e);
        }

        ImportSummary summary = new ImportSummary();
        summary.languageId = languageId;
        summary.stageId = stageId;
        summary.languages = 1;
        summary.stages = 1;
        summary.stageDesignNotes = data.notes.size();
        summary.stageStepTemplates = data.stepTemplates.size();
        summary.levelGroups = data.levelGroups.size();
        summary.levels = data.levels.size();
        summary.levelsWithGroup = countLevelsWithGroup(data.levels);
        summary.subLevels = data.subLevels.size();
        summary.questions = data.questions.size();
        summary.questionContents = data.questionContents.size();
        summary.sampleAnswers = data.sampleAnswers.size();
        return summary;
    }

    public BatchImportSummary importAllDocxToDatabase(String importFolderPath) {
        BatchImportSummary batchSummary = new BatchImportSummary();

        for (File file : listDocxFiles(importFolderPath)) {
            FileImportResult result = new FileImportResult();
            result.fileName = file.getName();

            try {
                result.summary = importDocxToDatabase(importFolderPath, file.getName());
                result.success = true;
                batchSummary.successCount++;
            } catch (Exception e) {
                result.success = false;
                result.errorMessage = rootMessage(e);
                batchSummary.failedCount++;
            }

            batchSummary.results.add(result);
        }

        return batchSummary;
    }

    public ImportSummary verifyEngStage1InDatabase(String languageId, String stageId) {
        return verifyImportInDatabase(languageId, stageId);
    }

    public ImportSummary verifyImportInDatabase(String languageId, String stageId) {
        ImportSummary summary = new ImportSummary();
        summary.languageId = languageId;
        summary.stageId = stageId;

        try (Connection conn = DBConnection.getConnection();
                Statement st = conn.createStatement()) {
            summary.languages = queryCount(st, "SELECT COUNT(*) FROM Languages WHERE LanguageId = '" + languageId + "'");
            summary.stages = queryCount(st, "SELECT COUNT(*) FROM Stages WHERE StageId = '" + stageId + "'");
            summary.stageDesignNotes = queryCount(st, "SELECT COUNT(*) FROM StageDesignNotes WHERE StageId = '" + stageId + "'");
            summary.stageStepTemplates = queryCount(st, "SELECT COUNT(*) FROM StageStepTemplates WHERE StageId = '" + stageId + "'");
            summary.levelGroups = queryCount(st, "SELECT COUNT(*) FROM LevelGroups WHERE StageId = '" + stageId + "'");
            summary.levels = queryCount(st, "SELECT COUNT(*) FROM Levels WHERE StageId = '" + stageId + "'");
            summary.levelsWithGroup = queryCount(st,
                    "SELECT COUNT(*) FROM Levels WHERE StageId = '" + stageId + "' AND GroupId IS NOT NULL");
            summary.subLevels = queryCount(st,
                    "SELECT COUNT(*) FROM SubLevel WHERE LevelId IN (SELECT LevelId FROM Levels WHERE StageId = '"
                            + stageId + "')");
            summary.questions = queryCount(st,
                    "SELECT COUNT(*) FROM Questions WHERE SubLevelId IN (SELECT SubLevelId FROM SubLevel WHERE LevelId IN "
                            + "(SELECT LevelId FROM Levels WHERE StageId = '" + stageId + "'))");
            summary.questionContents = queryCount(st,
                    "SELECT COUNT(*) FROM QuestionContent WHERE QuestionId IN (SELECT QuestionId FROM Questions WHERE SubLevelId IN "
                            + "(SELECT SubLevelId FROM SubLevel WHERE LevelId IN (SELECT LevelId FROM Levels WHERE StageId = '"
                            + stageId + "')))");
            summary.sampleAnswers = queryCount(st,
                    "SELECT COUNT(*) FROM SampleAnswers WHERE QuestionId IN (SELECT QuestionId FROM Questions WHERE SubLevelId IN "
                            + "(SELECT SubLevelId FROM SubLevel WHERE LevelId IN (SELECT LevelId FROM Levels WHERE StageId = '"
                            + stageId + "')))");
        } catch (Exception e) {
            throw new RuntimeException("Loi verify du lieu import cua stage: " + stageId, e);
        }

        return summary;
    }

    private void parseTokens(ParsedImportData data, List<Token> tokens) {
        LevelGroupRow currentGroup = null;
        LevelRow currentLevel = null;
        SubLevelRow currentSubLevel = null;
        QuestionRow currentQuestion = null;
        QuestionContentRow currentQuestionContent = null;
        SampleAnswerRow currentAnswer = null;
        String currentNoteType = null;
        StepTemplateRow currentTemplate = null;

        for (Token token : tokens) {
            String key = normalizeKey(token.key);
            String value = cleanValue(token.value);
            if (value.isBlank()) {
                continue;
            }

            switch (key) {
                case "languagename":
                    data.languageName = value;
                    break;
                case "descriptions":
                    data.stage.descriptions = append(data.stage.descriptions, value);
                    break;
                case "durationminutes":
                    data.stage.durationMinutes = parseInteger(value);
                    break;
                case "subdurationmins":
                    data.stage.subDurationMins = parseInteger(value);
                    break;
                case "stagenumber":
                    data.stage.stageNumber = parseInteger(value);
                    break;
                case "cefrstart":
                case "ceftstart":
                    data.stage.cefrStart = value;
                    break;
                case "cefrend":
                case "ceftend":
                    data.stage.cefrEnd = value;
                    break;
                case "levelstart":
                    data.stage.levelStart = parseInteger(value);
                    break;
                case "levelend":
                    data.stage.levelEnd = parseInteger(value);
                    break;
                case "completionoutcome":
                    data.stage.completionOutcome = value;
                    break;
                case "notetype":
                    currentNoteType = value;
                    break;
                case "contenttext":
                case "notetext":
                    data.notes.add(new NoteRow(currentNoteType == null ? "Note" : currentNoteType,
                            data.notes.size() + 1, value));
                    break;
                case "templatesteptitle":
                case "steptitle":
                    currentTemplate = new StepTemplateRow("StageStep", data.stepTemplates.size() + 1, value);
                    data.stepTemplates.add(currentTemplate);
                    break;
                case "templatedurationminutes":
                    if (currentTemplate == null) {
                        currentTemplate = new StepTemplateRow("StageStep", data.stepTemplates.size() + 1, "Step");
                        data.stepTemplates.add(currentTemplate);
                    }
                    currentTemplate.durationMinutes = parseInteger(value);
                    break;
                case "templatedescription":
                    if (currentTemplate != null) {
                        currentTemplate.description = value;
                    }
                    break;
                case "grouptitle":
                    currentGroup = new LevelGroupRow(data.levelGroups.size() + 1);
                    currentGroup.groupTitle = value;
                    data.levelGroups.add(currentGroup);
                    break;
                case "grcefrlevel":
                case "cefrlevel":
                    currentGroup = ensureCurrentGroup(data, currentGroup);
                    currentGroup.grCefrLevel = value;
                    break;
                case "grlevelstart":
                    currentGroup = ensureCurrentGroup(data, currentGroup);
                    currentGroup.levelStart = parseInteger(value);
                    break;
                case "grlevelend":
                    currentGroup = ensureCurrentGroup(data, currentGroup);
                    currentGroup.levelEnd = parseInteger(value);
                    break;
                case "levelnumber":
                    currentLevel = new LevelRow(parseInteger(value));
                    currentLevel.levelTitle = extractTextAfterFirstInteger(value);
                    currentLevel.groupNumber = currentGroup == null ? null : currentGroup.groupNumber;
                    data.levels.add(currentLevel);
                    currentSubLevel = null;
                    currentQuestion = null;
                    currentQuestionContent = null;
                    currentAnswer = null;
                    break;
                case "leveltitle":
                    if (currentLevel == null || isMeaningfulTitle(currentLevel.levelTitle)) {
                        currentLevel = new LevelRow(inferNextLevelNumber(data, currentGroup));
                        currentLevel.groupNumber = currentGroup == null ? null : currentGroup.groupNumber;
                        data.levels.add(currentLevel);
                        currentSubLevel = null;
                    }
                    currentLevel.levelTitle = value;
                    break;
                case "leveldescription":
                    currentLevel = ensureCurrentLevel(data, currentLevel, currentGroup);
                    currentLevel.levelDescription = append(currentLevel.levelDescription, value);
                    break;
                case "subleveltitle":
                    currentLevel = ensureCurrentLevel(data, currentLevel, currentGroup);
                    currentSubLevel = new SubLevelRow(currentLevel.levelNumber,
                            nextSubLevelNumber(data, currentLevel.levelNumber), value);
                    data.subLevels.add(currentSubLevel);
                    currentQuestion = null;
                    currentQuestionContent = null;
                    currentAnswer = null;
                    break;
                case "sublevelnumber":
                    currentLevel = ensureCurrentLevel(data, currentLevel, currentGroup);
                    currentSubLevel = new SubLevelRow(currentLevel.levelNumber, parseInteger(value), null);
                    data.subLevels.add(currentSubLevel);
                    currentQuestion = null;
                    currentQuestionContent = null;
                    currentAnswer = null;
                    break;
                case "maintask":
                    currentLevel = ensureCurrentLevel(data, currentLevel, currentGroup);
                    currentSubLevel = ensureCurrentSubLevel(data, currentSubLevel, currentLevel);
                    currentSubLevel.mainTask = append(currentSubLevel.mainTask, value);
                    break;
                case "prompthint":
                    currentLevel = ensureCurrentLevel(data, currentLevel, currentGroup);
                    currentSubLevel = ensureCurrentSubLevel(data, currentSubLevel, currentLevel);
                    currentSubLevel.promptHint = value;
                    break;
                case "questionnumber":
                    currentLevel = ensureCurrentLevel(data, currentLevel, currentGroup);
                    currentSubLevel = ensureCurrentSubLevel(data, currentSubLevel, currentLevel);
                    currentQuestion = new QuestionRow(currentSubLevel.levelNumber, currentSubLevel.subLevelNumber,
                            parseInteger(value));
                    data.questions.add(currentQuestion);
                    currentQuestionContent = null;
                    currentAnswer = null;
                    break;
                case "questiontype":
                    currentQuestion = ensureCurrentQuestion(data, currentQuestion, currentSubLevel, currentLevel);
                    currentQuestion.questionType = value;
                    break;
                case "difficultylevel":
                    currentQuestion = ensureCurrentQuestion(data, currentQuestion, currentSubLevel, currentLevel);
                    currentQuestion.difficultyLevel = value;
                    break;
                case "skilltarget":
                    currentQuestion = ensureCurrentQuestion(data, currentQuestion, currentSubLevel, currentLevel);
                    currentQuestion.skillTarget = value;
                    break;
                case "questiontext":
                    currentQuestion = ensureCurrentQuestion(data, currentQuestion, currentSubLevel, currentLevel);
                    currentQuestionContent = ensureQuestionContent(data, currentQuestionContent, currentQuestion);
                    currentQuestionContent.questionText = value;
                    break;
                case "queromanization":
                    currentQuestion = ensureCurrentQuestion(data, currentQuestion, currentSubLevel, currentLevel);
                    currentQuestionContent = ensureQuestionContent(data, currentQuestionContent, currentQuestion);
                    currentQuestionContent.romanization = value;
                    break;
                case "translation":
                    if (currentAnswer != null) {
                        currentAnswer.translation = value;
                    } else {
                        currentQuestion = ensureCurrentQuestion(data, currentQuestion, currentSubLevel, currentLevel);
                        currentQuestionContent = ensureQuestionContent(data, currentQuestionContent, currentQuestion);
                        currentQuestionContent.translation = value;
                    }
                    break;
                case "grammarnote":
                    currentQuestion = ensureCurrentQuestion(data, currentQuestion, currentSubLevel, currentLevel);
                    currentQuestionContent = ensureQuestionContent(data, currentQuestionContent, currentQuestion);
                    currentQuestionContent.grammarNote = value;
                    break;
                case "pronunciationnote":
                    currentQuestion = ensureCurrentQuestion(data, currentQuestion, currentSubLevel, currentLevel);
                    currentQuestionContent = ensureQuestionContent(data, currentQuestionContent, currentQuestion);
                    currentQuestionContent.pronunciationNote = value;
                    break;
                case "examplecontext":
                    currentQuestion = ensureCurrentQuestion(data, currentQuestion, currentSubLevel, currentLevel);
                    currentQuestionContent = ensureQuestionContent(data, currentQuestionContent, currentQuestion);
                    currentQuestionContent.exampleContext = value;
                    break;
                case "answerorder":
                    currentQuestion = ensureCurrentQuestion(data, currentQuestion, currentSubLevel, currentLevel);
                    currentAnswer = new SampleAnswerRow(currentQuestion.levelNumber, currentQuestion.subLevelNumber,
                            currentQuestion.questionNumber, parseInteger(value));
                    data.sampleAnswers.add(currentAnswer);
                    break;
                case "answertext":
                    currentQuestion = ensureCurrentQuestion(data, currentQuestion, currentSubLevel, currentLevel);
                    currentAnswer = ensureCurrentAnswer(data, currentAnswer, currentQuestion);
                    currentAnswer.answerText = value;
                    break;
                case "ansromanization":
                    currentQuestion = ensureCurrentQuestion(data, currentQuestion, currentSubLevel, currentLevel);
                    currentAnswer = ensureCurrentAnswer(data, currentAnswer, currentQuestion);
                    currentAnswer.romanization = value;
                    break;
                default:
                    break;
            }
        }
    }

    private List<Token> tokenize(List<String> rawLines) {
        String text = String.join("\n", rawLines);
        Matcher matcher = KEY_VALUE_PATTERN.matcher(text);
        List<TokenMatch> matches = new ArrayList<>();

        while (matcher.find()) {
            matches.add(new TokenMatch(matcher.start(), matcher.end(), matcher.group(1)));
        }

        List<Token> tokens = new ArrayList<>();
        for (int i = 0; i < matches.size(); i++) {
            TokenMatch current = matches.get(i);
            int valueEnd = i + 1 < matches.size() ? matches.get(i + 1).start : text.length();
            tokens.add(new Token(current.key, text.substring(current.end, valueEnd)));
        }

        return tokens;
    }

    private void upsertLanguage(Connection conn, String languageId, String languageName) throws Exception {
        String sql = "INSERT INTO Languages (LanguageId, LanguageName) VALUES (?, ?) "
                + "ON DUPLICATE KEY UPDATE LanguageName = VALUES(LanguageName)";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, languageId);
            ps.setString(2, truncate(languageName, 50));
            ps.executeUpdate();
        }
    }

    private void upsertStage(Connection conn, String stageId, String languageId, StageRow stage) throws Exception {
        String sql = "INSERT INTO Stages (StageId, LanguageId, StageNumber, DurationMinutes, CefrStart, CefrEnd, "
                + "LevelStart, LevelEnd, CompletionOutcome, Descriptions, IsStatus) "
                + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?) "
                + "ON DUPLICATE KEY UPDATE LanguageId = VALUES(LanguageId), StageNumber = VALUES(StageNumber), "
                + "DurationMinutes = VALUES(DurationMinutes), CefrStart = VALUES(CefrStart), CefrEnd = VALUES(CefrEnd), "
                + "LevelStart = VALUES(LevelStart), LevelEnd = VALUES(LevelEnd), "
                + "CompletionOutcome = VALUES(CompletionOutcome), Descriptions = VALUES(Descriptions), "
                + "IsStatus = VALUES(IsStatus)";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, stageId);
            ps.setString(2, languageId);
            setInteger(ps, 3, stage.stageNumber);
            setInteger(ps, 4, stage.durationMinutes);
            ps.setString(5, truncate(stage.cefrStart, 20));
            ps.setString(6, truncate(stage.cefrEnd, 20));
            ps.setInt(7, stage.levelStart);
            ps.setInt(8, stage.levelEnd);
            ps.setString(9, truncate(stage.completionOutcome, 255));
            ps.setString(10, truncate(stage.descriptions, 255));
            ps.setInt(11, 1);
            ps.executeUpdate();
        }
    }

    private void insertStageNotes(Connection conn, String stageId, List<NoteRow> notes) throws Exception {
        String sql = "INSERT INTO StageDesignNotes (NoteId, StageId, NoteType, NoteOrder, ContentText) "
                + "VALUES (?, ?, ?, ?, ?)";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            for (NoteRow note : notes) {
                ps.setString(1, stageId + "_NOTE_" + note.noteOrder);
                ps.setString(2, stageId);
                ps.setString(3, truncate(note.noteType, 50));
                ps.setInt(4, note.noteOrder);
                ps.setString(5, note.contentText);
                ps.addBatch();
            }
            ps.executeBatch();
        }
    }

    private void insertStageStepTemplates(Connection conn, String stageId, List<StepTemplateRow> templates)
            throws Exception {
        String sql = "INSERT INTO StageStepTemplates "
                + "(StageStepTemplateId, StageId, TemplateType, TemplateStepOrder, TemplateStepTitle, "
                + "TemplateDurationMinutes, TemplateDescription, IsStatus) VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            for (StepTemplateRow template : templates) {
                ps.setString(1, stageId + "_TPL_" + template.stepOrder);
                ps.setString(2, stageId);
                ps.setString(3, truncate(template.templateType, 50));
                ps.setInt(4, template.stepOrder);
                ps.setString(5, truncate(template.title, 100));
                setInteger(ps, 6, template.durationMinutes);
                ps.setString(7, truncate(template.description, 255));
                ps.setInt(8, 1);
                ps.addBatch();
            }
            ps.executeBatch();
        }
    }

    private void insertLevelGroups(Connection conn, String stageId, List<LevelGroupRow> groups) throws Exception {
        String sql = "INSERT INTO LevelGroups (GroupId, StageId, GroupTitle, GrCefrLevel, GrLevelStart, GrLevelEnd) "
                + "VALUES (?, ?, ?, ?, ?, ?)";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            for (LevelGroupRow group : groups) {
                ps.setString(1, buildGroupId(stageId, group.groupNumber));
                ps.setString(2, stageId);
                ps.setString(3, truncate(group.groupTitle, 100));
                ps.setString(4, truncate(group.grCefrLevel, 50));
                setInteger(ps, 5, group.levelStart);
                setInteger(ps, 6, group.levelEnd);
                ps.addBatch();
            }
            ps.executeBatch();
        }
    }

    private void insertLevels(Connection conn, String stageId, List<LevelRow> levels) throws Exception {
        String sql = "INSERT INTO Levels (LevelId, GroupId, StageId, LevelTitle, LevelNumber, LevelDescription) "
                + "VALUES (?, ?, ?, ?, ?, ?)";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            for (LevelRow level : levels) {
                ps.setString(1, buildLevelId(stageId, level.levelNumber));
                ps.setString(2, level.groupNumber == null ? null : buildGroupId(stageId, level.groupNumber));
                ps.setString(3, stageId);
                ps.setString(4, truncate(level.levelTitle, 100));
                ps.setInt(5, level.levelNumber);
                ps.setString(6, level.levelDescription);
                ps.addBatch();
            }
            ps.executeBatch();
        }
    }

    private void insertSubLevels(Connection conn, String stageId, List<SubLevelRow> subLevels) throws Exception {
        String sql = "INSERT INTO SubLevel "
                + "(SubLevelId, LevelId, SubLevelNumber, SublevelTitle, MainTask, PromptHint, SubDurationMins) "
                + "VALUES (?, ?, ?, ?, ?, ?, ?)";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            for (SubLevelRow subLevel : subLevels) {
                String levelId = buildLevelId(stageId, subLevel.levelNumber);
                ps.setString(1, buildSubLevelId(stageId, subLevel.levelNumber, subLevel.subLevelNumber));
                ps.setString(2, levelId);
                setInteger(ps, 3, subLevel.subLevelNumber);
                ps.setString(4, truncate(subLevel.subLevelTitle, 100));
                ps.setString(5, truncate(subLevel.mainTask, 255));
                ps.setString(6, truncate(subLevel.promptHint, 255));
                setInteger(ps, 7, subLevel.subDurationMins);
                ps.addBatch();
            }
            ps.executeBatch();
        }
    }

    private void insertQuestions(Connection conn, String stageId, List<QuestionRow> questions) throws Exception {
        String sql = "INSERT INTO Questions "
                + "(QuestionId, SubLevelId, QuestionNumber, QuestionType, DifficultyLevel, SkillTarget) "
                + "VALUES (?, ?, ?, ?, ?, ?)";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            for (QuestionRow question : questions) {
                ps.setString(1, buildQuestionId(stageId, question));
                ps.setString(2, buildSubLevelId(stageId, question.levelNumber, question.subLevelNumber));
                setInteger(ps, 3, question.questionNumber);
                ps.setString(4, truncate(question.questionType, 50));
                ps.setString(5, truncate(question.difficultyLevel, 50));
                ps.setString(6, truncate(question.skillTarget, 100));
                ps.addBatch();
            }
            ps.executeBatch();
        }
    }

    private void insertQuestionContents(Connection conn, String stageId, String languageId,
            List<QuestionContentRow> contents) throws Exception {
        String sql = "INSERT INTO QuestionContent "
                + "(QuestionContentId, QuestionId, LanguageId, QuestionText, QueRomanization, Translation, "
                + "GrammarNote, PronunciationNote, ExampleContext) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            for (QuestionContentRow content : contents) {
                String questionId = buildQuestionId(stageId, content);
                ps.setString(1, questionId + "_" + languageId);
                ps.setString(2, questionId);
                ps.setString(3, languageId);
                ps.setString(4, content.questionText == null ? "" : content.questionText);
                ps.setString(5, content.romanization);
                ps.setString(6, content.translation);
                ps.setString(7, truncate(content.grammarNote, 255));
                ps.setString(8, truncate(content.pronunciationNote, 255));
                ps.setString(9, truncate(content.exampleContext, 255));
                ps.addBatch();
            }
            ps.executeBatch();
        }
    }

    private void insertSampleAnswers(Connection conn, String stageId, String languageId, List<SampleAnswerRow> answers)
            throws Exception {
        String sql = "INSERT INTO SampleAnswers "
                + "(AnswerId, QuestionId, LanguageId, AnswerText, AnsRomanization, Translation, AnswerOrder) "
                + "VALUES (?, ?, ?, ?, ?, ?, ?)";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            for (SampleAnswerRow answer : answers) {
                String questionId = buildQuestionId(stageId, answer);
                int answerOrder = answer.answerOrder == null ? 1 : answer.answerOrder;
                ps.setString(1, questionId + "_A_" + answerOrder + "_" + answer.sequence);
                ps.setString(2, questionId);
                ps.setString(3, languageId);
                ps.setString(4, answer.answerText);
                ps.setString(5, answer.romanization);
                ps.setString(6, answer.translation);
                ps.setInt(7, answerOrder);
                ps.addBatch();
            }
            ps.executeBatch();
        }
    }

    private void deleteExistingStageData(Connection conn, String stageId) throws Exception {
        String[] sqlStatements = {
                "DELETE f FROM Feedback f JOIN UserAnswers ua ON ua.UserAnswersId = f.UserAnswerId "
                        + "JOIN Questions q ON q.QuestionId = ua.QuestionId JOIN SubLevel sl ON sl.SubLevelId = q.SubLevelId "
                        + "JOIN Levels l ON l.LevelId = sl.LevelId WHERE l.StageId = ?",
                "DELETE ua FROM UserAnswers ua JOIN Questions q ON q.QuestionId = ua.QuestionId "
                        + "JOIN SubLevel sl ON sl.SubLevelId = q.SubLevelId JOIN Levels l ON l.LevelId = sl.LevelId "
                        + "WHERE l.StageId = ?",
                "DELETE a FROM AISuggestions a LEFT JOIN Questions q ON q.QuestionId = a.QuestionId "
                        + "LEFT JOIN SubLevel sl ON sl.SubLevelId = COALESCE(a.SubLevelId, q.SubLevelId) "
                        + "LEFT JOIN Levels l ON l.LevelId = sl.LevelId WHERE l.StageId = ?",
                "DELETE sa FROM SampleAnswers sa JOIN Questions q ON q.QuestionId = sa.QuestionId "
                        + "JOIN SubLevel sl ON sl.SubLevelId = q.SubLevelId JOIN Levels l ON l.LevelId = sl.LevelId "
                        + "WHERE l.StageId = ?",
                "DELETE qc FROM QuestionContent qc JOIN Questions q ON q.QuestionId = qc.QuestionId "
                        + "JOIN SubLevel sl ON sl.SubLevelId = q.SubLevelId JOIN Levels l ON l.LevelId = sl.LevelId "
                        + "WHERE l.StageId = ?",
                "DELETE q FROM Questions q JOIN SubLevel sl ON sl.SubLevelId = q.SubLevelId "
                        + "JOIN Levels l ON l.LevelId = sl.LevelId WHERE l.StageId = ?",
                "DELETE ls FROM LearningSessions ls JOIN Levels l ON l.LevelId = ls.LevelId WHERE l.StageId = ?",
                "DELETE up FROM UserProgress up JOIN Levels l ON l.LevelId = up.LevelId WHERE l.StageId = ?",
                "DELETE pm FROM PinnedMaterials pm JOIN SubLevel sl ON sl.SubLevelId = pm.SubLevelId "
                        + "JOIN Levels l ON l.LevelId = sl.LevelId WHERE l.StageId = ?",
                "DELETE rp FROM RoomParticipants rp JOIN Rooms r ON r.RoomId = rp.RoomId "
                        + "JOIN Levels l ON l.LevelId = r.LevelId WHERE l.StageId = ?",
                "DELETE gt FROM GiftTransactions gt JOIN Rooms r ON r.RoomId = gt.RoomId "
                        + "JOIN Levels l ON l.LevelId = r.LevelId WHERE l.StageId = ?",
                "DELETE pr FROM PodcastRecords pr JOIN Rooms r ON r.RoomId = pr.RoomId "
                        + "JOIN Levels l ON l.LevelId = r.LevelId WHERE l.StageId = ?",
                "DELETE r FROM Rooms r JOIN Levels l ON l.LevelId = r.LevelId WHERE l.StageId = ?",
                "DELETE FROM StageStepTemplates WHERE StageId = ?",
                "DELETE FROM StageDesignNotes WHERE StageId = ?",
                "DELETE sl FROM SubLevel sl JOIN Levels l ON l.LevelId = sl.LevelId WHERE l.StageId = ?",
                "DELETE FROM Levels WHERE StageId = ?",
                "DELETE FROM LevelGroups WHERE StageId = ?"
        };

        for (String sql : sqlStatements) {
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setString(1, stageId);
                ps.executeUpdate();
            }
        }
    }

    private File[] listDocxFiles(String importFolderPath) {
        File importFolder = new File(importFolderPath);
        if (!importFolder.exists() || !importFolder.isDirectory()) {
            throw new IllegalArgumentException("Khong tim thay folder: " + importFolder.getPath());
        }

        File[] files = importFolder.listFiles((dir, name) -> isImportableDocx(name));
        if (files == null || files.length == 0) {
            throw new IllegalArgumentException("Khong tim thay file .docx trong folder: " + importFolder.getPath());
        }

        Arrays.sort(files, (first, second) -> first.getName().compareToIgnoreCase(second.getName()));
        return files;
    }

    private void ensureFile(File file) {
        if (!file.exists() || !file.isFile()) {
            throw new IllegalArgumentException("Khong tim thay file: " + file.getPath());
        }
    }

    private boolean isImportableDocx(String name) {
        String normalized = name.toLowerCase(Locale.ROOT);
        return normalized.endsWith(".docx") && !normalized.startsWith("~$");
    }

    private void applyFileNameFallbacks(ParsedImportData data, String targetFileName) {
        if (isBlank(data.languageName)) {
            data.languageName = inferLanguageName(targetFileName);
        }

        if (data.stage.stageNumber == null) {
            data.stage.stageNumber = inferStageNumber(targetFileName);
        }

        int[] range = inferLevelRange(targetFileName);
        if (data.stage.levelStart == null && range[0] != 0) {
            data.stage.levelStart = range[0];
        }
        if (data.stage.levelEnd == null && range[1] != 0) {
            data.stage.levelEnd = range[1];
        }

        if (isBlank(data.stage.descriptions) && data.languageName != null && data.stage.stageNumber != null) {
            data.stage.descriptions = data.languageName + " Stage " + data.stage.stageNumber;
        }
    }

    private void createGroupsIfNeeded(ParsedImportData data) {
        if (!data.levelGroups.isEmpty() || data.stage.levelStart == null || data.stage.levelEnd == null) {
            return;
        }

        int groupStart = data.stage.levelStart;
        while (groupStart <= data.stage.levelEnd) {
            int groupEnd = Math.min(groupStart + 4, data.stage.levelEnd);
            LevelGroupRow group = new LevelGroupRow(data.levelGroups.size() + 1);
            group.levelStart = groupStart;
            group.levelEnd = groupEnd;
            data.levelGroups.add(group);
            groupStart = groupEnd + 1;
        }
    }

    private void applyContentLevelRange(ParsedImportData data) {
        Integer min = null;
        Integer max = null;
        for (LevelRow level : data.levels) {
            if (level.levelNumber == null) {
                continue;
            }
            min = min == null ? level.levelNumber : Math.min(min, level.levelNumber);
            max = max == null ? level.levelNumber : Math.max(max, level.levelNumber);
        }

        if (min != null && (data.stage.levelStart == null || min < data.stage.levelStart)) {
            data.stage.levelStart = min;
        }
        if (max != null && (data.stage.levelEnd == null || max > data.stage.levelEnd)) {
            data.stage.levelEnd = max;
        }
    }

    private void assignLevelsToGroups(ParsedImportData data) {
        for (LevelRow level : data.levels) {
            if (level.groupNumber != null || level.levelNumber == null) {
                continue;
            }

            LevelGroupRow group = findGroupByLevelNumber(data.levelGroups, level.levelNumber);
            if (group != null) {
                level.groupNumber = group.groupNumber;
            }
        }
    }

    private void createDefaultSubLevelsForQuestions(ParsedImportData data) {
        for (QuestionRow question : data.questions) {
            if (!hasSubLevel(data, question.levelNumber, question.subLevelNumber)) {
                data.subLevels.add(new SubLevelRow(question.levelNumber, question.subLevelNumber, null));
            }
        }
    }

    private void applyStageDefaultsToSubLevels(ParsedImportData data) {
        if (data.stage.subDurationMins == null) {
            return;
        }

        for (SubLevelRow subLevel : data.subLevels) {
            if (subLevel.subDurationMins == null) {
                subLevel.subDurationMins = data.stage.subDurationMins;
            }
        }
    }

    private LevelGroupRow ensureCurrentGroup(ParsedImportData data, LevelGroupRow currentGroup) {
        if (currentGroup != null) {
            return currentGroup;
        }

        LevelGroupRow group = new LevelGroupRow(data.levelGroups.size() + 1);
        data.levelGroups.add(group);
        return group;
    }

    private LevelRow ensureCurrentLevel(ParsedImportData data, LevelRow currentLevel, LevelGroupRow currentGroup) {
        if (currentLevel != null) {
            return currentLevel;
        }

        LevelRow level = new LevelRow(inferNextLevelNumber(data, currentGroup));
        level.groupNumber = currentGroup == null ? null : currentGroup.groupNumber;
        data.levels.add(level);
        return level;
    }

    private SubLevelRow ensureCurrentSubLevel(ParsedImportData data, SubLevelRow currentSubLevel, LevelRow currentLevel) {
        if (currentSubLevel != null) {
            return currentSubLevel;
        }

        SubLevelRow subLevel = new SubLevelRow(currentLevel.levelNumber, nextSubLevelNumber(data, currentLevel.levelNumber),
                null);
        data.subLevels.add(subLevel);
        return subLevel;
    }

    private QuestionRow ensureCurrentQuestion(ParsedImportData data, QuestionRow currentQuestion,
            SubLevelRow currentSubLevel, LevelRow currentLevel) {
        if (currentQuestion != null) {
            return currentQuestion;
        }

        SubLevelRow subLevel = ensureCurrentSubLevel(data, currentSubLevel, currentLevel);
        QuestionRow question = new QuestionRow(subLevel.levelNumber, subLevel.subLevelNumber,
                nextQuestionNumber(data, subLevel.levelNumber, subLevel.subLevelNumber));
        data.questions.add(question);
        return question;
    }

    private QuestionContentRow ensureQuestionContent(ParsedImportData data, QuestionContentRow currentContent,
            QuestionRow question) {
        if (currentContent != null && currentContent.sameQuestion(question)) {
            return currentContent;
        }

        QuestionContentRow content = new QuestionContentRow(question);
        data.questionContents.add(content);
        return content;
    }

    private SampleAnswerRow ensureCurrentAnswer(ParsedImportData data, SampleAnswerRow currentAnswer,
            QuestionRow question) {
        if (currentAnswer != null && currentAnswer.sameQuestion(question)) {
            return currentAnswer;
        }

        SampleAnswerRow answer = new SampleAnswerRow(question.levelNumber, question.subLevelNumber,
                question.questionNumber, nextAnswerOrder(data, question));
        data.sampleAnswers.add(answer);
        return answer;
    }

    private Integer inferNextLevelNumber(ParsedImportData data, LevelGroupRow currentGroup) {
        if (currentGroup != null && currentGroup.levelStart != null && currentGroup.levelEnd != null) {
            int usedInGroup = 0;
            for (LevelRow level : data.levels) {
                if (level.levelNumber != null
                        && level.levelNumber >= currentGroup.levelStart
                        && level.levelNumber <= currentGroup.levelEnd) {
                    usedInGroup++;
                }
            }

            int inferred = currentGroup.levelStart + usedInGroup;
            if (inferred <= currentGroup.levelEnd) {
                return inferred;
            }
        }

        int max = 0;
        for (LevelRow level : data.levels) {
            if (level.levelNumber != null && level.levelNumber > max) {
                max = level.levelNumber;
            }
        }
        return max + 1;
    }

    private int nextSubLevelNumber(ParsedImportData data, Integer levelNumber) {
        int max = 0;
        for (SubLevelRow subLevel : data.subLevels) {
            if (levelNumber != null && levelNumber.equals(subLevel.levelNumber)
                    && subLevel.subLevelNumber != null && subLevel.subLevelNumber > max) {
                max = subLevel.subLevelNumber;
            }
        }
        return max + 1;
    }

    private int nextQuestionNumber(ParsedImportData data, Integer levelNumber, Integer subLevelNumber) {
        int max = 0;
        for (QuestionRow question : data.questions) {
            if (levelNumber.equals(question.levelNumber) && subLevelNumber.equals(question.subLevelNumber)
                    && question.questionNumber != null && question.questionNumber > max) {
                max = question.questionNumber;
            }
        }
        return max + 1;
    }

    private int nextAnswerOrder(ParsedImportData data, QuestionRow question) {
        int max = 0;
        for (SampleAnswerRow answer : data.sampleAnswers) {
            if (answer.sameQuestion(question) && answer.answerOrder != null && answer.answerOrder > max) {
                max = answer.answerOrder;
            }
        }
        return max + 1;
    }

    private boolean hasSubLevel(ParsedImportData data, Integer levelNumber, Integer subLevelNumber) {
        for (SubLevelRow subLevel : data.subLevels) {
            if (levelNumber.equals(subLevel.levelNumber) && subLevelNumber.equals(subLevel.subLevelNumber)) {
                return true;
            }
        }
        return false;
    }

    private LevelGroupRow findGroupByLevelNumber(List<LevelGroupRow> groups, Integer levelNumber) {
        for (LevelGroupRow group : groups) {
            if (group.levelStart == null || group.levelEnd == null) {
                continue;
            }
            if (levelNumber >= group.levelStart && levelNumber <= group.levelEnd) {
                return group;
            }
        }
        return null;
    }

    private int countLevelsWithGroup(List<LevelRow> levels) {
        int count = 0;
        for (LevelRow level : levels) {
            if (level.groupNumber != null) {
                count++;
            }
        }
        return count;
    }

    private void validateForImport(ParsedImportData data, String targetFileName) {
        if (isBlank(data.languageName)) {
            throw new IllegalArgumentException("Thieu LanguageName trong file: " + targetFileName);
        }
        if (data.stage.stageNumber == null) {
            throw new IllegalArgumentException("Thieu StageNumber trong file: " + targetFileName);
        }
        if (data.stage.levelStart == null || data.stage.levelEnd == null) {
            throw new IllegalArgumentException("Thieu LevelStart hoac LevelEnd trong file: " + targetFileName);
        }
        if (data.levels.isEmpty()) {
            throw new IllegalArgumentException("Khong parse duoc Levels trong file: " + targetFileName);
        }
        for (LevelRow level : data.levels) {
            if (level.levelNumber == null) {
                throw new IllegalArgumentException("Co Level bi thieu LevelNumber trong file: " + targetFileName);
            }
        }
        for (SubLevelRow subLevel : data.subLevels) {
            if (subLevel.levelNumber == null || subLevel.subLevelNumber == null) {
                throw new IllegalArgumentException("Co SubLevel bi thieu LevelNumber/SubLevelNumber trong file: "
                        + targetFileName);
            }
        }
    }

    private String inferLanguageName(String targetFileName) {
        String normalized = targetFileName.toLowerCase(Locale.ROOT);
        if (normalized.contains("eng")) {
            return "English";
        }
        if (normalized.contains("japanese") || normalized.contains("janpanes")) {
            return "Japanese";
        }
        if (normalized.contains("chinese")) {
            return "Chinese";
        }
        return null;
    }

    private Integer inferStageNumber(String targetFileName) {
        Matcher explicit = Pattern.compile("(?i)stage\\s*(\\d+)|ステージ\\s*(\\d+)").matcher(targetFileName);
        if (explicit.find()) {
            return parseInteger(firstNonNull(explicit.group(1), explicit.group(2)));
        }

        int[] range = inferLevelRange(targetFileName);
        if (range[0] == 0) {
            return null;
        }
        if (range[0] <= 30) {
            return 1;
        }
        if (range[0] <= 60) {
            return 2;
        }
        return 3;
    }

    private int[] inferLevelRange(String targetFileName) {
        Matcher matcher = Pattern.compile("(?i)level(?:s)?\\s*(\\d+)\\s*-\\s*(\\d+)|レベル\\s*(\\d+)\\s*-\\s*(\\d+)")
                .matcher(targetFileName);
        if (!matcher.find()) {
            return new int[] { 0, 0 };
        }

        return new int[] {
                Integer.parseInt(firstNonNull(matcher.group(1), matcher.group(3))),
                Integer.parseInt(firstNonNull(matcher.group(2), matcher.group(4)))
        };
    }

    private String buildLanguageId(String languageName) {
        Map<String, String> languageIds = new LinkedHashMap<>();
        languageIds.put("english", "ENG");
        languageIds.put("eng", "ENG");
        languageIds.put("japanese", "JAP");
        languageIds.put("janpanes", "JAP");
        languageIds.put("chinese", "CHI");

        String normalized = languageName.trim().toLowerCase(Locale.ROOT);
        String languageId = languageIds.get(normalized);
        if (languageId != null) {
            return languageId;
        }
        return languageName.substring(0, Math.min(3, languageName.length())).toUpperCase(Locale.ROOT);
    }

    private String buildStageId(String languageId, Integer stageNumber) {
        return languageId + "_STAGE_" + stageNumber;
    }

    private String buildGroupId(String stageId, Integer groupNumber) {
        return stageId + "_GROUP_" + groupNumber;
    }

    private String buildLevelId(String stageId, Integer levelNumber) {
        return stageId + "_LEVEL_" + levelNumber;
    }

    private String buildSubLevelId(String stageId, Integer levelNumber, Integer subLevelNumber) {
        return buildLevelId(stageId, levelNumber) + "_SUB_" + subLevelNumber;
    }

    private String buildQuestionId(String stageId, QuestionRef question) {
        return buildSubLevelId(stageId, question.levelNumber(), question.subLevelNumber())
                + "_Q_" + question.questionNumber();
    }

    private int queryCount(Statement st, String sql) throws Exception {
        try (ResultSet rs = st.executeQuery(sql)) {
            rs.next();
            return rs.getInt(1);
        }
    }

    private void setInteger(PreparedStatement ps, int parameterIndex, Integer value) throws Exception {
        if (value == null) {
            ps.setNull(parameterIndex, Types.INTEGER);
            return;
        }
        ps.setInt(parameterIndex, value);
    }

    private Integer parseInteger(String value) {
        if (value == null) {
            return null;
        }

        Matcher matcher = Pattern.compile("\\d+").matcher(value);
        if (!matcher.find()) {
            return null;
        }
        return Integer.parseInt(matcher.group());
    }

    private String extractTextAfterFirstInteger(String value) {
        if (value == null) {
            return null;
        }

        String firstLine = value.split("\\R", 2)[0].trim();
        Matcher matcher = Pattern.compile("\\d+\\s*[.)、-]+\\s*(.+)$").matcher(firstLine);
        if (!matcher.find()) {
            return null;
        }

        String text = cleanValue(matcher.group(1));
        return isMeaningfulTitle(text) ? text : null;
    }

    private boolean isMeaningfulTitle(String value) {
        if (value == null || value.isBlank()) {
            return false;
        }

        return !value.matches("[\\d\\s.)、\\-–—]+");
    }

    private String normalizeKey(String key) {
        return key == null ? "" : key.replaceAll("\\s+", "").toLowerCase(Locale.ROOT);
    }

    private String cleanValue(String value) {
        if (value == null) {
            return "";
        }

        return value.replaceAll("(?m)^\\s*[\\p{So}\\u2022\\-–—]+\\s*", "")
                .replaceAll("\\s+", " ")
                .trim();
    }

    private String append(String existing, String value) {
        if (isBlank(existing)) {
            return value;
        }
        if (isBlank(value)) {
            return existing;
        }
        return existing + " | " + value;
    }

    private String truncate(String value, int maxLength) {
        if (value == null || value.length() <= maxLength) {
            return value;
        }
        return value.substring(0, maxLength);
    }

    private boolean isBlank(String value) {
        return value == null || value.isBlank();
    }

    private String firstNonNull(String first, String second) {
        return first != null ? first : second;
    }

    private String rootMessage(Exception e) {
        Throwable current = e;
        while (current.getCause() != null) {
            current = current.getCause();
        }
        return current.getMessage();
    }

    private interface QuestionRef {
        Integer levelNumber();

        Integer subLevelNumber();

        Integer questionNumber();
    }

    private static class TokenMatch {
        private final int start;
        private final int end;
        private final String key;

        private TokenMatch(int start, int end, String key) {
            this.start = start;
            this.end = end;
            this.key = key;
        }
    }

    private static class Token {
        private final String key;
        private final String value;

        private Token(String key, String value) {
            this.key = key;
            this.value = value;
        }
    }

    public static class ParsedImportData {
        public String sourceFileName;
        public String languageName;
        public final List<String> rawLines = new ArrayList<>();
        public final StageRow stage = new StageRow();
        public final List<NoteRow> notes = new ArrayList<>();
        public final List<StepTemplateRow> stepTemplates = new ArrayList<>();
        public final List<LevelGroupRow> levelGroups = new ArrayList<>();
        public final List<LevelRow> levels = new ArrayList<>();
        public final List<SubLevelRow> subLevels = new ArrayList<>();
        public final List<QuestionRow> questions = new ArrayList<>();
        public final List<QuestionContentRow> questionContents = new ArrayList<>();
        public final List<SampleAnswerRow> sampleAnswers = new ArrayList<>();
    }

    public static class StageRow {
        public String descriptions;
        public Integer durationMinutes;
        public Integer subDurationMins;
        public Integer stageNumber;
        public String cefrStart;
        public String cefrEnd;
        public Integer levelStart;
        public Integer levelEnd;
        public String completionOutcome;
    }

    public static class NoteRow {
        public final String noteType;
        public final Integer noteOrder;
        public final String contentText;

        public NoteRow(String noteType, Integer noteOrder, String contentText) {
            this.noteType = noteType;
            this.noteOrder = noteOrder;
            this.contentText = contentText;
        }
    }

    public static class StepTemplateRow {
        public final String templateType;
        public final Integer stepOrder;
        public final String title;
        public Integer durationMinutes;
        public String description;

        public StepTemplateRow(String templateType, Integer stepOrder, String title) {
            this.templateType = templateType;
            this.stepOrder = stepOrder;
            this.title = title;
        }
    }

    public static class LevelGroupRow {
        public final Integer groupNumber;
        public String groupTitle;
        public String grCefrLevel;
        public Integer levelStart;
        public Integer levelEnd;

        public LevelGroupRow(Integer groupNumber) {
            this.groupNumber = groupNumber;
        }
    }

    public static class LevelRow {
        public Integer groupNumber;
        public Integer levelNumber;
        public String levelTitle;
        public String levelDescription;

        public LevelRow(Integer levelNumber) {
            this.levelNumber = levelNumber;
        }
    }

    public static class SubLevelRow {
        public Integer levelNumber;
        public Integer subLevelNumber;
        public String subLevelTitle;
        public String mainTask;
        public String promptHint;
        public Integer subDurationMins;

        public SubLevelRow(Integer levelNumber, Integer subLevelNumber, String subLevelTitle) {
            this.levelNumber = levelNumber;
            this.subLevelNumber = subLevelNumber;
            this.subLevelTitle = subLevelTitle;
        }
    }

    public static class QuestionRow implements QuestionRef {
        public Integer levelNumber;
        public Integer subLevelNumber;
        public Integer questionNumber;
        public String questionType;
        public String difficultyLevel;
        public String skillTarget;

        public QuestionRow(Integer levelNumber, Integer subLevelNumber, Integer questionNumber) {
            this.levelNumber = levelNumber;
            this.subLevelNumber = subLevelNumber;
            this.questionNumber = questionNumber;
        }

        public Integer levelNumber() {
            return levelNumber;
        }

        public Integer subLevelNumber() {
            return subLevelNumber;
        }

        public Integer questionNumber() {
            return questionNumber;
        }
    }

    public static class QuestionContentRow implements QuestionRef {
        public Integer levelNumber;
        public Integer subLevelNumber;
        public Integer questionNumber;
        public String questionText;
        public String romanization;
        public String translation;
        public String grammarNote;
        public String pronunciationNote;
        public String exampleContext;

        public QuestionContentRow(QuestionRow question) {
            this.levelNumber = question.levelNumber;
            this.subLevelNumber = question.subLevelNumber;
            this.questionNumber = question.questionNumber;
        }

        public boolean sameQuestion(QuestionRow question) {
            return levelNumber.equals(question.levelNumber)
                    && subLevelNumber.equals(question.subLevelNumber)
                    && questionNumber.equals(question.questionNumber);
        }

        public Integer levelNumber() {
            return levelNumber;
        }

        public Integer subLevelNumber() {
            return subLevelNumber;
        }

        public Integer questionNumber() {
            return questionNumber;
        }
    }

    public static class SampleAnswerRow implements QuestionRef {
        private static int nextSequence = 1;

        public final int sequence;
        public Integer levelNumber;
        public Integer subLevelNumber;
        public Integer questionNumber;
        public Integer answerOrder;
        public String answerText;
        public String romanization;
        public String translation;

        public SampleAnswerRow(Integer levelNumber, Integer subLevelNumber, Integer questionNumber,
                Integer answerOrder) {
            this.sequence = nextSequence++;
            this.levelNumber = levelNumber;
            this.subLevelNumber = subLevelNumber;
            this.questionNumber = questionNumber;
            this.answerOrder = answerOrder;
        }

        public boolean sameQuestion(QuestionRow question) {
            return levelNumber.equals(question.levelNumber)
                    && subLevelNumber.equals(question.subLevelNumber)
                    && questionNumber.equals(question.questionNumber);
        }

        public Integer levelNumber() {
            return levelNumber;
        }

        public Integer subLevelNumber() {
            return subLevelNumber;
        }

        public Integer questionNumber() {
            return questionNumber;
        }
    }

    public static class ImportSummary {
        public String languageId;
        public String stageId;
        public int languages;
        public int stages;
        public int stageDesignNotes;
        public int stageStepTemplates;
        public int levelGroups;
        public int levels;
        public int levelsWithGroup;
        public int subLevels;
        public int questions;
        public int questionContents;
        public int sampleAnswers;

        @Override
        public String toString() {
            return "LanguageId=" + languageId
                    + ", StageId=" + stageId
                    + ", Languages=" + languages
                    + ", Stages=" + stages
                    + ", StageDesignNotes=" + stageDesignNotes
                    + ", StageStepTemplates=" + stageStepTemplates
                    + ", LevelGroups=" + levelGroups
                    + ", Levels=" + levels
                    + ", LevelsWithGroup=" + levelsWithGroup
                    + ", SubLevels=" + subLevels
                    + ", Questions=" + questions
                    + ", QuestionContents=" + questionContents
                    + ", SampleAnswers=" + sampleAnswers;
        }
    }

    public static class FileImportResult {
        public String fileName;
        public boolean success;
        public ImportSummary summary;
        public String errorMessage;

        @Override
        public String toString() {
            if (success) {
                return "SUCCESS: " + fileName + " -> " + summary;
            }
            return "FAILED: " + fileName + " -> " + errorMessage;
        }
    }

    public static class BatchImportSummary {
        public final List<FileImportResult> results = new ArrayList<>();
        public int successCount;
        public int failedCount;

        @Override
        public String toString() {
            return "Success=" + successCount + ", Failed=" + failedCount;
        }
    }
}
