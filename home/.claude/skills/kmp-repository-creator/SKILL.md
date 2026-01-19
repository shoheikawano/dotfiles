---
name: kmp-repository-creator
description: |
  Generate Repository classes for Kotlin Multiplatform (KMP) projects using Ktor for networking and multiplatform-settings for local storage.
  Use when: (1) Creating data layer repositories, (2) Implementing network data fetching with Ktor,
  (3) Adding local caching with multiplatform-settings, (4) Writing repository unit tests,
  (5) Following TDD workflow for repository implementation.
  Triggers: repository, data layer, ktor, multiplatform-settings, network fetch, local storage,
  cache, data source, TDD repository, repository pattern, kmp repository.
context: fork
agent: general-purpose
user-invocable: true
allowed-tools:
  - Read
  - Write
  - Edit
  - Glob
  - Grep
  - Bash
---

# KMP Repository Creator

Generate Repository classes following TDD methodology with Ktor networking and multiplatform-settings caching.

## Coding Standards

**MANDATORY**: Follow [kotlin-compose-standards](../kotlin-compose-standards/skill.md):
- Trailing comma EXCEPT for Modifier arguments
- New line at end of file

## TDD Workflow

**Always follow Red-Green-Refactor cycle:**

1. **RED** - Write failing test first
2. **GREEN** - Implement minimal code to pass
3. **REFACTOR** - Improve code while keeping tests green

See [references/tdd-workflow.md](references/tdd-workflow.md) for detailed TDD patterns.

## Repository Structure

```
feature/
  data/
    repository/
      UserRepository.kt          # Interface
      UserRepositoryImpl.kt      # Implementation
    datasource/
      UserRemoteDataSource.kt    # Ktor network calls
      UserLocalDataSource.kt     # multiplatform-settings
    model/
      UserDto.kt                 # Network DTOs
  domain/
    model/
      User.kt                    # Domain models
```

## Quick Start

### 1. Define Repository Interface

```kotlin
interface UserRepository {
    suspend fun getUser(id: String): User
    suspend fun getUsers(): List<User>
    fun observeUser(id: String): Flow<User?>
}
```

### 2. Write Tests First (TDD)

```kotlin
class UserRepositoryImplTest {
    private lateinit var repository: UserRepository
    private val remoteDataSource = FakeUserRemoteDataSource()
    private val localDataSource = FakeUserLocalDataSource()

    @BeforeTest
    fun setup() {
        repository = UserRepositoryImpl(remoteDataSource, localDataSource)
    }

    @Test
    fun `getUser returns cached user when available`() = runTest {
        // Given
        val cachedUser = User(id = "1", name = "John")
        localDataSource.saveUser(cachedUser)

        // When
        val result = repository.getUser("1")

        // Then
        assertEquals(cachedUser, result)
    }

    @Test
    fun `getUser fetches from remote when cache empty`() = runTest {
        // Given
        val remoteUser = UserDto(id = "1", name = "John")
        remoteDataSource.setResponse(remoteUser)

        // When
        val result = repository.getUser("1")

        // Then
        assertEquals("John", result.name)
    }

    @Test
    fun `getUser throws exception when network fails`() = runTest {
        // Given
        remoteDataSource.setError(IOException("Network error"))

        // When/Then
        assertFailsWith<IOException> {
            repository.getUser("1")
        }
    }
}
```

### 3. Implement Repository

```kotlin
class UserRepositoryImpl(
    private val remoteDataSource: UserRemoteDataSource,
    private val localDataSource: UserLocalDataSource,
) : UserRepository {

    override suspend fun getUser(id: String): User {
        // Try cache first
        localDataSource.getUser(id)?.let { return it }

        // Fetch from remote
        val dto = remoteDataSource.getUser(id)
        val user = dto.toDomain()
        localDataSource.saveUser(user)
        return user
    }

    override suspend fun getUsers(): List<User> {
        return remoteDataSource.getUsers().map { it.toDomain() }
    }

    override fun observeUser(id: String): Flow<User?> {
        return localDataSource.observeUser(id)
    }
}
```

## Workflow

1. **Analyze requirements** - What data? Caching strategy?
2. **Define interface** - Repository contract with suspend functions
3. **Write tests** - Cover cache hit, cache miss, error cases
4. **Implement minimal** - Just enough to pass tests
5. **Refactor** - Extract data sources, improve error handling
6. **Verify** - Run tests, ensure all pass

## References

| File | When to Read |
|------|--------------|
| [ktor-patterns.md](references/ktor-patterns.md) | Network calls, error handling, serialization |
| [multiplatform-settings.md](references/multiplatform-settings.md) | Local storage, caching patterns |
| [tdd-workflow.md](references/tdd-workflow.md) | TDD cycle, test patterns, fake implementations |
| [testing-patterns.md](references/testing-patterns.md) | Test doubles, coroutine testing |

## Koin Integration

Repository injected via Koin DSL:

```kotlin
val dataModule = module {
    // Data sources
    single { UserRemoteDataSource(get()) }
    single { UserLocalDataSource(get()) }

    // Repository
    single<UserRepository> { UserRepositoryImpl(get(), get()) }
}
```

ViewModel receives repository:

```kotlin
class UserViewModel(
    private val userRepository: UserRepository,
) : ViewModel() {

    private val _uiState = MutableStateFlow<UserUiState>(UserUiState.Loading)
    val uiState: StateFlow<UserUiState> = _uiState.asStateFlow()

    fun loadUser(id: String) {
        viewModelScope.launch {
            _uiState.value = UserUiState.Loading
            try {
                val user = userRepository.getUser(id)
                _uiState.value = UserUiState.Success(user)
            } catch (e: Exception) {
                _uiState.value = UserUiState.Error(e.message)
            }
        }
    }
}
```

## Best Practices

- Repository throws exceptions for errors (ViewModel handles with try-catch)
- Use `Flow<T>` for observable data
- Keep domain models separate from DTOs
- Cache strategy: cache-first with network fallback
- Test all paths: success, cache hit, network error
