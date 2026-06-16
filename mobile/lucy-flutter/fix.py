import sys

filepath = r"d:\LucyProject\mobile\lucy-flutter\lib\screens\lucy_pro_home.dart"

with open(filepath, "r", encoding="utf-8") as f:
    content = f.read()

target = """                          color: AppColors.textSecondary, fontSize: 11)),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _isStudyStarted && active != null
                      ? _completeActiveSubLevel
                      : null,
                  icon: const Icon(Icons.skip_next, size: 16),
                  label: Text(_activeSubLevelIndex >=
                          ((plan?.subLevels.length ?? 1) - 1)
                      ? 'Hoàn tất'
                      : 'Sublevel tiếp'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
        ],"""

replacement = """                          color: AppColors.textSecondary, fontSize: 11)),
                  ],
                  const SizedBox(height: 4),
                  Text('${active.durationMins ?? widget.duration} phút',
                      style: const TextStyle(
                          color: AppColors.primaryDark,
                          fontSize: 10,
                          fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _isStudyStarted ? null : _startStudyFlow,
                  icon: const Icon(Icons.play_arrow, size: 16),
                  label: const Text('Bắt đầu học'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _isStudyStarted && active != null
                      ? () {
                          final isLast = _activeSubLevelIndex >= ((plan?.subLevels.length ?? 1) - 1);
                          if (isLast) {
                            _showSendQuizDialog();
                          } else {
                            _completeActiveSubLevel();
                          }
                        }
                      : null,
                  icon: const Icon(Icons.skip_next, size: 16),
                  label: Text(_getNextButtonLabel(plan, _activeSubLevelIndex)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
        ],"""

if target in content:
    content = content.replace(target, replacement)
    with open(filepath, "w", encoding="utf-8") as f:
        f.write(content)
    print("Success")
else:
    print("Target not found")
