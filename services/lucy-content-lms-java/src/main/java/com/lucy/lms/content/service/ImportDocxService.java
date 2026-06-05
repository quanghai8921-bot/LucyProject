package com.lucy.lms.content.service;

import java.io.File;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.Locale;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import org.springframework.stereotype.Service;

import com.lucy.lms.content.utils.DocxReader;

@Service
public class ImportDocxService {
    private static final Pattern KEY_VALUE_PATTERN = Pattern.compile(
            "(?i)(?<![A-Za-z])("
                    + "TemplateDurationMinutes|TemplateDescription|TemplateStepTitle|"
                    + "QuestionNumber|QuestionType|QuestionText|QueRomanization|"
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
    private final ContentImportPersistenceService persistenceService;

    public ImportDocxService(DocxReader docxReader, ContentImportPersistenceService persistenceService) {
        this.docxReader = docxReader;
        this.persistenceService = persistenceService;
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
            System.out.println(
                    "  Level " + level.levelNumber + " group=" + level.groupNumber + " title=" + level.levelTitle);
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

        try {
            return persistenceService.importData(data);
        } catch (Exception e) {
            throw new RuntimeException("Loi import file " + targetFileName + ": " + e.getMessage(), e);
        }
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
        return persistenceService.verifyImport(languageId, stageId);
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

    private SubLevelRow ensureCurrentSubLevel(ParsedImportData data, SubLevelRow currentSubLevel,
            LevelRow currentLevel) {
        if (currentSubLevel != null) {
            return currentSubLevel;
        }

        SubLevelRow subLevel = new SubLevelRow(currentLevel.levelNumber,
                nextSubLevelNumber(data, currentLevel.levelNumber),
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
