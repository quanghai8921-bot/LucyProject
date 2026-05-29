package com.lucy.lms.content.service;

import java.util.LinkedHashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.lucy.lms.content.model.Language;
import com.lucy.lms.content.model.LearningLevel;
import com.lucy.lms.content.model.LevelGroup;
import com.lucy.lms.content.model.Question;
import com.lucy.lms.content.model.QuestionContent;
import com.lucy.lms.content.model.SampleAnswer;
import com.lucy.lms.content.model.Stage;
import com.lucy.lms.content.model.StageDesignNote;
import com.lucy.lms.content.model.StageStepTemplate;
import com.lucy.lms.content.model.SubLevel;
import com.lucy.lms.content.repository.LanguageRepository;
import com.lucy.lms.content.repository.LearningLevelRepository;
import com.lucy.lms.content.repository.LevelGroupRepository;
import com.lucy.lms.content.repository.QuestionContentRepository;
import com.lucy.lms.content.repository.QuestionRepository;
import com.lucy.lms.content.repository.SampleAnswerRepository;
import com.lucy.lms.content.repository.StageDesignNoteRepository;
import com.lucy.lms.content.repository.StageRepository;
import com.lucy.lms.content.repository.StageStepTemplateRepository;
import com.lucy.lms.content.repository.SubLevelRepository;
import com.lucy.lms.content.service.ImportDocxService.ImportSummary;
import com.lucy.lms.content.service.ImportDocxService.ParsedImportData;

@Service
public class ContentImportPersistenceService {

    private final LanguageRepository languageRepository;
    private final StageRepository stageRepository;
    private final StageDesignNoteRepository stageDesignNoteRepository;
    private final StageStepTemplateRepository stageStepTemplateRepository;
    private final LevelGroupRepository levelGroupRepository;
    private final LearningLevelRepository learningLevelRepository;
    private final SubLevelRepository subLevelRepository;
    private final QuestionRepository questionRepository;
    private final QuestionContentRepository questionContentRepository;
    private final SampleAnswerRepository sampleAnswerRepository;

    public ContentImportPersistenceService(
            LanguageRepository languageRepository,
            StageRepository stageRepository,
            StageDesignNoteRepository stageDesignNoteRepository,
            StageStepTemplateRepository stageStepTemplateRepository,
            LevelGroupRepository levelGroupRepository,
            LearningLevelRepository learningLevelRepository,
            SubLevelRepository subLevelRepository,
            QuestionRepository questionRepository,
            QuestionContentRepository questionContentRepository,
            SampleAnswerRepository sampleAnswerRepository) {
        this.languageRepository = languageRepository;
        this.stageRepository = stageRepository;
        this.stageDesignNoteRepository = stageDesignNoteRepository;
        this.stageStepTemplateRepository = stageStepTemplateRepository;
        this.levelGroupRepository = levelGroupRepository;
        this.learningLevelRepository = learningLevelRepository;
        this.subLevelRepository = subLevelRepository;
        this.questionRepository = questionRepository;
        this.questionContentRepository = questionContentRepository;
        this.sampleAnswerRepository = sampleAnswerRepository;
    }

    @Transactional
    public ImportSummary importData(ParsedImportData data) {
        String languageId = buildLanguageId(data.languageName);
        String stageId = buildStageId(languageId, data.stage.stageNumber);

        languageRepository.save(new Language(languageId, truncate(data.languageName, 50)));
        stageRepository.save(new Stage(
                stageId,
                languageId,
                data.stage.stageNumber,
                data.stage.durationMinutes,
                truncate(data.stage.cefrStart, 20),
                truncate(data.stage.cefrEnd, 20),
                data.stage.levelStart,
                data.stage.levelEnd,
                truncate(data.stage.completionOutcome, 255),
                truncate(data.stage.descriptions, 255),
                1));

        stageDesignNoteRepository.saveAll(data.notes.stream()
                .map(note -> new StageDesignNote(
                        stageId + "_NOTE_" + note.noteOrder,
                        stageId,
                        truncate(note.noteType, 50),
                        note.noteOrder,
                        note.contentText))
                .toList());

        stageStepTemplateRepository.saveAll(data.stepTemplates.stream()
                .map(template -> new StageStepTemplate(
                        stageId + "_TPL_" + template.stepOrder,
                        stageId,
                        truncate(template.templateType, 50),
                        template.stepOrder,
                        truncate(template.title, 100),
                        template.durationMinutes,
                        truncate(template.description, 255),
                        1))
                .toList());

        levelGroupRepository.saveAll(data.levelGroups.stream()
                .map(group -> new LevelGroup(
                        buildGroupId(stageId, group.groupNumber),
                        stageId,
                        truncate(group.groupTitle, 100),
                        truncate(group.grCefrLevel, 50),
                        group.levelStart,
                        group.levelEnd))
                .toList());

        learningLevelRepository.saveAll(data.levels.stream()
                .map(level -> new LearningLevel(
                        buildLevelId(stageId, level.levelNumber),
                        level.groupNumber == null ? null : buildGroupId(stageId, level.groupNumber),
                        stageId,
                        truncate(level.levelTitle, 100),
                        level.levelNumber,
                        level.levelDescription))
                .toList());

        subLevelRepository.saveAll(data.subLevels.stream()
                .map(subLevel -> new SubLevel(
                        buildSubLevelId(stageId, subLevel.levelNumber, subLevel.subLevelNumber),
                        buildLevelId(stageId, subLevel.levelNumber),
                        subLevel.subLevelNumber,
                        truncate(subLevel.subLevelTitle, 100),
                        truncate(subLevel.mainTask, 255),
                        truncate(subLevel.promptHint, 255),
                        subLevel.subDurationMins))
                .toList());

        questionRepository.saveAll(data.questions.stream()
                .map(question -> new Question(
                        buildQuestionId(stageId, question),
                        buildSubLevelId(stageId, question.levelNumber, question.subLevelNumber),
                        question.questionNumber,
                        truncate(question.questionType, 50)))
                .toList());

        questionContentRepository.saveAll(data.questionContents.stream()
                .map(content -> {
                    String questionId = buildQuestionId(stageId, content);
                    return new QuestionContent(
                            questionId + "_" + languageId,
                            questionId,
                            languageId,
                            content.questionText == null ? "" : content.questionText,
                            content.romanization,
                            content.translation,
                            truncate(content.grammarNote, 255),
                            truncate(content.pronunciationNote, 255),
                            truncate(content.exampleContext, 255));
                })
                .toList());

        sampleAnswerRepository.saveAll(data.sampleAnswers.stream()
                .map(answer -> {
                    String questionId = buildQuestionId(stageId, answer);
                    int answerOrder = answer.answerOrder == null ? 1 : answer.answerOrder;
                    return new SampleAnswer(
                            questionId + "_A_" + answerOrder + "_" + answer.sequence,
                            questionId,
                            languageId,
                            answer.answerText,
                            answer.romanization,
                            answer.translation,
                            answerOrder);
                })
                .toList());

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

    @Transactional(readOnly = true)
    public ImportSummary verifyImport(String languageId, String stageId) {
        List<String> levelIds = learningLevelRepository.findByStageId(stageId).stream()
                .map(LearningLevel::getLevelId)
                .toList();
        List<String> subLevelIds = levelIds.isEmpty()
                ? List.of()
                : subLevelRepository.findByLevelIdIn(levelIds).stream().map(SubLevel::getSubLevelId).toList();
        List<String> questionIds = subLevelIds.isEmpty()
                ? List.of()
                : questionRepository.findBySubLevelIdIn(subLevelIds).stream().map(Question::getQuestionId).toList();

        ImportSummary summary = new ImportSummary();
        summary.languageId = languageId;
        summary.stageId = stageId;
        summary.languages = languageRepository.existsById(languageId) ? 1 : 0;
        summary.stages = stageRepository.existsById(stageId) ? 1 : 0;
        summary.stageDesignNotes = (int) stageDesignNoteRepository.countByStageId(stageId);
        summary.stageStepTemplates = (int) stageStepTemplateRepository.countByStageId(stageId);
        summary.levelGroups = (int) levelGroupRepository.countByStageId(stageId);
        summary.levels = (int) learningLevelRepository.countByStageId(stageId);
        summary.levelsWithGroup = (int) learningLevelRepository.countByStageIdAndGroupIdIsNotNull(stageId);
        summary.subLevels = levelIds.isEmpty() ? 0 : (int) subLevelRepository.countByLevelIdIn(levelIds);
        summary.questions = subLevelIds.isEmpty() ? 0 : (int) questionRepository.countBySubLevelIdIn(subLevelIds);
        summary.questionContents = questionIds.isEmpty() ? 0 : (int) questionContentRepository.countByQuestionIdIn(questionIds);
        summary.sampleAnswers = questionIds.isEmpty() ? 0 : (int) sampleAnswerRepository.countByQuestionIdIn(questionIds);
        return summary;
    }

    private int countLevelsWithGroup(List<ImportDocxService.LevelRow> levels) {
        int count = 0;
        for (ImportDocxService.LevelRow level : levels) {
            if (level.groupNumber != null) {
                count++;
            }
        }
        return count;
    }

    private String buildLanguageId(String languageName) {
        Map<String, String> languageIds = new LinkedHashMap<>();
        languageIds.put("english", "ENG");
        languageIds.put("eng", "ENG");
        languageIds.put("japanese", "JAP");
        languageIds.put("janpanes", "JAP");
        languageIds.put("chinese", "CHI");

        String normalized = languageName.trim().toLowerCase(Locale.ROOT);
        if (languageIds.containsKey(normalized)) {
            return languageIds.get(normalized);
        }

        return normalized.replaceAll("[^a-z0-9]+", "_").replaceAll("^_|_$", "").toUpperCase(Locale.ROOT);
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

    private String buildQuestionId(String stageId, ImportDocxService.QuestionRow question) {
        return buildQuestionId(stageId, question.levelNumber, question.subLevelNumber, question.questionNumber);
    }

    private String buildQuestionId(String stageId, ImportDocxService.QuestionContentRow question) {
        return buildQuestionId(stageId, question.levelNumber, question.subLevelNumber, question.questionNumber);
    }

    private String buildQuestionId(String stageId, ImportDocxService.SampleAnswerRow question) {
        return buildQuestionId(stageId, question.levelNumber, question.subLevelNumber, question.questionNumber);
    }

    private String buildQuestionId(String stageId, Integer levelNumber, Integer subLevelNumber, Integer questionNumber) {
        return buildSubLevelId(stageId, levelNumber, subLevelNumber) + "_Q_" + questionNumber;
    }

    private String truncate(String value, int maxLength) {
        if (value == null || value.length() <= maxLength) {
            return value;
        }
        return value.substring(0, maxLength);
    }
}
