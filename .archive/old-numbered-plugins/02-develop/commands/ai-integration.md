---
allowed-tools: Task, Read, Write, Bash, Glob, Grep, AskUserQuestion
description: Add AI/LLM capabilities to application
argument-hint: <feature-type>
---

**Arguments**: $ARGUMENTS

## Step 1: Detect Project State

Check if project is initialized:

!{bash test -f .claude/project.json && echo "✅ Project initialized" || echo "⚠️ No project.json - run /core:init first"}

## Step 2: Load Project Context

@.claude/project.json

## Step 3: Check for Existing AI Integration

!{bash grep -r "openai\|anthropic\|langchain\|llamaindex" . --include="package.json" --include="requirements.txt" --include="go.mod" 2>/dev/null || echo "No existing AI dependencies"}

## Step 4: Delegate to AI Integrator Agent

Task(
  description="Add AI capabilities",
  subagent_type="ai-integrator",
  prompt="Integrate AI/LLM capabilities into the application.

**Feature Type**: $ARGUMENTS (e.g., chat, embeddings, completions, image generation)

**Instructions**:

1. **Detect Project Stack**:
   - Read .claude/project.json to understand framework
   - Identify backend language (Node.js, Python, Go, etc.)
   - Check for existing AI libraries

2. **Choose AI Provider**:
   - Ask user which provider (OpenAI, Anthropic, local models)
   - Or detect from existing dependencies
   - Consider cost and performance requirements

3. **Install Dependencies**:
   - Add appropriate AI SDK/library
   - OpenAI: openai, @ai-sdk/openai
   - Anthropic: @anthropic-ai/sdk
   - LangChain: langchain, @langchain/core
   - LlamaIndex: llamaindex
   - Local: ollama, llama.cpp

4. **Implement AI Features**:

   **For Chat/Completions**:
   - Create API endpoint for chat
   - Add streaming support
   - Include conversation history management
   - Add rate limiting and error handling

   **For Embeddings**:
   - Create embedding generation endpoint
   - Add vector storage (Pinecone, Weaviate, ChromaDB)
   - Implement similarity search
   - Add document chunking

   **For Image Generation**:
   - Add image generation endpoint
   - Include prompt engineering
   - Add image storage/CDN integration

   **For Function Calling/Tools**:
   - Define tool schemas
   - Implement tool execution
   - Add result formatting

5. **Add Environment Configuration**:
   - Create .env.example with API key placeholders
   - Add configuration loading
   - Include provider URL configuration for local models

6. **Security & Best Practices**:
   - Secure API key storage
   - Input validation and sanitization
   - Output filtering (content moderation)
   - Cost controls and usage limits
   - Error handling and fallbacks

7. **Generate Tests**:
   - Mock AI provider responses
   - Test error handling
   - Test rate limiting
   - Test streaming (if applicable)

8. **Add Documentation**:
   - API endpoint documentation
   - Configuration instructions
   - Usage examples
   - Cost considerations

**Project-Agnostic Design**:
- ❌ NEVER hardcode provider or framework
- ✅ DO support multiple AI providers
- ✅ DO adapt to detected backend stack
- ✅ DO work with ANY project type

**Deliverables**:
- AI integration code with proper error handling
- Environment configuration template
- Tests with mocked responses
- Documentation with examples
- Cost and usage guidelines
"
)

## Step 5: Review Results

Display AI integration summary and configuration instructions.
