# Lucy Content LMS

Spring Boot MVC application scaffold.

## Run

```powershell
mvn spring-boot:run
```

Open:

- `http://localhost:8080/`
- `http://localhost:8080/api/health`

## Package Structure

- `com.lucy.lms.common`: shared primitives, configuration, and helpers
- `com.lucy.lms.content`: content data and import flows for Languages, Stages, Levels, SubLevels, questions, and sample answers
- `com.lucy.lms.learner`: learner-facing features owned by Vinh
- `com.lucy.lms.mentor`: mentor-facing features owned by Kim
- `com.lucy.lms.creator`: creator-facing features owned by Dat
- `com.lucy.lms.admin`: LMS admin operations
- `resources/templates`: Thymeleaf MVC pages
- `resources/static`: static assets
