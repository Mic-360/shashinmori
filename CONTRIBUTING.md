# Contributing to ShashinMori API

Thank you for your interest in contributing to ShashinMori API! We welcome contributions from everyone, regardless of experience level. This document provides guidelines and instructions for contributing.

## Code of Conduct

We are committed to providing a friendly and respectful community. Please be respectful, inclusive, and professional in all interactions.

## Ways to Contribute

- **Report Bugs**: Submit detailed bug reports with reproduction steps
- **Suggest Features**: Share ideas for new features or improvements
- **Write Code**: Submit pull requests with bug fixes or features
- **Improve Documentation**: Fix typos, clarify instructions, or add examples
- **Share Feedback**: Let us know what works and what doesn't

## Getting Started

### Setting Up Development Environment

1. **Fork the repository**

   ```bash
   git clone https://github.com/mic-360/shashinmori.git -b shashinmori-api
   cd shashinmori
   ```

2. **Create a development branch**

   ```bash
   git checkout -b feature/your-feature-name
   ```

3. **Install dependencies**

   ```bash
   npm install
   ```

4. **Setup environment configuration**
   ```bash
   cp .env.example .env
   # Edit .env with your Firebase configuration
   ```

## Development Workflow

### Before You Start

- Check [existing issues](https://github.com/mic-360/shashinmori/issues) to avoid duplicate work
- For major features, open a discussion first to get feedback
- Familiarize yourself with the [architecture](docs/architecture.md)

### Making Changes

1. **Create a feature branch**

   ```bash
   git checkout -b feature/descriptive-name
   ```

2. **Install TypeScript** and compile

   ```bash
   npm run build
   ```

3. **Run development server with watch mode**

   ```bash
   npm run dev
   npm run dev:workers  # in another terminal
   ```

4. **Test your changes**

   ```bash
   # Manual testing with curl
   curl http://localhost:3000/v1/system/health
   ```

5. **Type check your code**

   ```bash
   npx tsc --noEmit
   ```

6. **Keep commits clean and focused**
   ```bash
   git commit -m "Feature: add photo deletion"
   git commit -m "Fix: resolve upload timeout issue"
   git commit -m "Docs: update API documentation"
   ```

### Commit Message Guidelines

Use clear, descriptive commit messages:

- `Feature: add photo deletion endpoint`
- `Fix: resolve storage guard worker timeout`
- `Docs: update Termux deployment guide`
- `Tests: add upload worker tests`
- `Refactor: improve error handling`

Format: `<type>: <description>`

### Code Style

#### TypeScript Best Practices

- Use `const` by default, `let` when needed, avoid `var`
- Write explicit type annotations for function parameters
- Avoid `any` types; use proper TypeScript types
- Use interfaces for object shapes
- Prefer arrow functions for consistency

#### Example

```typescript
interface PhotoUploadJob {
  uploadId: string;
  uid: string;
  filePath: string;
}

async function processPhotoUpload(job: PhotoUploadJob): Promise<void> {
  const { uploadId, uid, filePath } = job;

  // Implementation
}
```

### Naming Conventions

- Constants: `const MAX_UPLOAD_SIZE = 2147483648`
- Variables: `const uploadId = ...`
- Functions: `async function processUpload()`
- Classes: `class PhotoProcessor`
- Interfaces: `interface IUploadJob`
- Private members: `#privateField` or `_privateVariable`

### Error Handling

Always provide meaningful error messages:

```typescript
try {
  await processUpload(file);
} catch (error) {
  logger.error({
    message: 'Upload processing failed',
    uploadId,
    error: error instanceof Error ? error.message : 'Unknown error',
  });
  throw new UploadError('Failed to process upload', uploadId);
}
```

## Database Changes

### Adding Firestore Collections

If your changes require new Firestore data:

1. Document the collection schema in a comment
2. Add validation using Zod schemas
3. Update [docs/architecture.md](docs/architecture.md)
4. Create migration guide if needed

Example:

```typescript
// Schema for photos/{photoId}
interface Photo {
  uid: string;
  filename: string;
  mimeType: string;
  uploadedAt: Timestamp;
  originalAvailable: boolean;
}

const PhotoSchema = z.object({
  uid: z.string(),
  filename: z.string(),
  mimeType: z.string(),
  uploadedAt: z.instanceof(Timestamp),
  originalAvailable: z.boolean(),
});
```

## API Changes

### Adding Endpoints

When adding new API routes:

1. Add route handler in `/src/routes/v1/`
2. Update Swagger schema with `@schema` decorators
3. Document in [docs/api.md](docs/api.md)
4. Add authentication checks
5. Include proper error responses

### Updating Requests/Responses

If changing request/response formats:

1. Update Zod validation schemas
2. Update TypeScript types in `src/types/`
3. Update Swagger documentation
4. Document breaking changes in PR

## Testing

### Manual API Testing

```bash
# Health check
curl http://localhost:3000/v1/system/health

# Authenticated request (replace with real token)
curl -H "Authorization: Bearer $FIREBASE_TOKEN" \
     http://localhost:3000/v1/system/status

# Create upload
curl -X POST \
     -H "Authorization: Bearer $FIREBASE_TOKEN" \
     -H "Upload-Length: 1024000" \
     http://localhost:3000/v1/uploads
```

### Testing Workers

1. Enable debug logging:

   ```bash
   LOG_LEVEL=debug npm run dev:workers
   ```

2. Trigger jobs manually or via API
3. Watch for job processing in logs
4. Check Firestore for updated records

### Integration Testing

Create test scenarios that verify:

- Upload end-to-end flow
- Worker processing
- Firestore updates
- File storage in correct locations

## Pull Request Process

1. **Fork and create a feature branch**

   ```bash
   git checkout -b feature/your-feature
   ```

2. **Make your changes**
   - Keep changes focused and manageable
   - Update documentation if needed
   - Add tests for new functionality

3. **Verify code quality**

   ```bash
   npx tsc --noEmit
   npm run build
   ```

4. **Push to your fork**

   ```bash
   git push origin feature/your-feature
   ```

5. **Create a Pull Request**
   - Use a clear, descriptive title
   - Reference related issues (#123)
   - Describe what changes were made and why
   - List any breaking changes

### PR Title Format

- `Feature: add photo deletion`
- `Fix: resolve worker timeout`
- `Docs: update setup guide`
- `Refactor: improve type safety`
- `Tests: add upload tests`

### PR Description Template

```markdown
## Description

Brief summary of changes

## Related Issues

Fixes #123

## Changes Made

- Change 1
- Change 2
- Change 3

## Testing Done

- Tested on Node.js 20
- Verified Redis connection
- Tested with sample upload

## Breaking Changes

None / Description of breaking changes

## Checklist

- [ ] Code compiles without errors (`npm run build`)
- [ ] Type checking passes (`npx tsc --noEmit`)
- [ ] Updated documentation if needed
- [ ] Code follows project style guidelines
- [ ] Tested locally with different scenarios
```

## Reporting Issues

### Before Reporting

- Search [existing issues](https://github.com/mic-360/shashinmori/issues) first
- Try the [troubleshooting guide](README.md#troubleshooting)

### Issue Template

```markdown
### Environment

- Node.js version: 20.x.x
- OS: Windows / macOS / Linux
- Configuration: Local / Docker / Termux

### Steps to Reproduce

1. Step 1
2. Step 2
3. Step 3

### Expected Behavior

What should happen

### Actual Behavior

What actually happens

### Error Logs
```

[Paste error logs here - use LOG_LEVEL=debug]

```

### Configuration
```

[Paste .env config - redact Firebase keys]

```

```

## Feature Requests

Feature requests are welcome! Please provide:

- **Clear title**: What feature?
- **Motivation**: Why is it needed?
- **Use case**: How does this help?
- **Alternatives**: Are there other solutions?
- **Implementation ideas**: (optional)

## Documentation

Documentation improvements are always welcome:

- Fix typos or unclear explanations
- Add examples or code snippets
- Add troubleshooting guides
- Improve API documentation
- Add deployment instructions

## Development Tips

### Useful Commands

```bash
# Type checking
npx tsc --noEmit

# Build production
npm run build

# Run with verbose logging
LOG_LEVEL=debug npm run dev

# Check environment
npm run build && npm start

# Clean build
rm -rf dist/ node_modules/ package-lock.json
npm install && npm run build
```

### Debugging

```bash
# Enable debug logs
LOG_LEVEL=debug npm run dev

# Debug workers
LOG_LEVEL=debug npm run dev:workers

# Inspect with Node debugger
node --inspect dist/index.js
```

### Performance Testing

```bash
# Monitor storage
node -e "console.log(require('os').platform())"

# Test Redis connection
npm list bullmq
```

## Getting Help

- **Questions**: Open a [GitHub Discussion](https://github.com/mic-360/shashinmori/discussions)
- **Issues**: Check [troubleshooting](README.md#troubleshooting)
- **Documentation**: See [docs/](docs/) folder
- **Community**: Discord (if available)

## Recognition

Contributors will be:

- Listed in the project README
- Credited in version CHANGELOG
- Thanked in pull request discussions

## Code Review

All submissions require review. We review for:

- Code quality and TypeScript correctness
- Performance implications
- Security considerations
- Architecture alignment
- Documentation completeness
- Error handling

## License

By contributing, you agree that your contributions will be licensed under the MIT License.

---

Thank you for contributing to ShashinMori! Your efforts help make this project better for everyone.
