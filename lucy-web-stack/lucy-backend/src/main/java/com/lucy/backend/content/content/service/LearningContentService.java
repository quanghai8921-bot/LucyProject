package com.lucy.backend.content.content.service;

import java.util.List;
import java.util.stream.Collectors;

import org.springframework.stereotype.Service;

import com.lucy.backend.content.content.dto.LevelContentDto;
import com.lucy.backend.content.content.dto.SubLevelContentDto;
import com.lucy.backend.content.content.model.Language;
import com.lucy.backend.content.content.model.LearningLevel;
import com.lucy.backend.content.content.model.Stage;
import com.lucy.backend.content.content.model.SubLevel;
import com.lucy.backend.content.content.repository.LanguageRepository;
import com.lucy.backend.content.content.repository.LearningLevelRepository;
import com.lucy.backend.content.content.repository.StageRepository;
import com.lucy.backend.content.content.repository.SubLevelRepository;

@Service
public class LearningContentService {

    private final LanguageRepository languageRepository;
    private final StageRepository stageRepository;
    private final LearningLevelRepository levelRepository;
    private final SubLevelRepository subLevelRepository;

    public LearningContentService(LanguageRepository languageRepository, StageRepository stageRepository,
            LearningLevelRepository levelRepository, SubLevelRepository subLevelRepository) {
        this.languageRepository = languageRepository;
        this.stageRepository = stageRepository;
        this.levelRepository = levelRepository;
        this.subLevelRepository = subLevelRepository;
    }

    public LevelContentDto getLevelContent(String languageName, Integer levelNumber) {
        if (languageName == null || levelNumber == null) {
            throw new IllegalArgumentException("LanguageName and LevelNumber must be provided");
        }

        LearningLevel targetLevel = levelRepository.findByLanguageNameAndLevelNumber(languageName, levelNumber)
                .orElseThrow(() -> new IllegalArgumentException("Level " + levelNumber + " not found for language " + languageName));

        List<SubLevel> subLevels = subLevelRepository.findByLevelIdOrderBySubLevelNumberAsc(targetLevel.getLevelId());
        
        List<SubLevelContentDto> subLevelDtos = subLevels.stream()
                .map(sl -> new SubLevelContentDto(sl.getSublevelTitle(), sl.getMainTask()))
                .collect(Collectors.toList());

        return new LevelContentDto(targetLevel.getLevelNumber(), targetLevel.getLevelTitle(), subLevelDtos);
    }
}
