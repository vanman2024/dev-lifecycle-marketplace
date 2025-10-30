---
allowed-tools: Bash, Write, Edit, MultiEdit, WebFetch
description: Build complete FastMCP server with full documentation and reference links
---

# Build Complete FastMCP Server

**Arguments**: $ARGUMENTS

## FastMCP Complete Documentation & Templates

### 🚨 CRITICAL: Agent Instructions for Using MCP Servers

**Before making ANY tool calls to an MCP server, agents MUST:**

1. **Check Available Resources**:
   ```python
   # First, list resources to understand what documentation is available
   resources = await list_resources(server="server-name")
   
   # Read critical resources like usage guides
   guide = await read_resource(server="server-name", uri="resource://usage_guide")
   ```

2. **Review Prompts** (if supported by the client):
   ```python
   # Prompts provide parameterized guidance
   # Example: Get specific guidance for your use case
   prompt_result = await get_prompt("implementation_guide", 
                                   feature_type="dashboard", 
                                   technology="React")
   ```

3. **Understand Server Patterns**:
   - Resources explain HOW to use the server
   - Prompts provide dynamic, context-specific guidance
   - Both should be consulted BEFORE making tool calls

4. **Example Agent Workflow**:
   ```
   Agent Task: "Use V0 Enhanced to create a dashboard"
   
   Step 1: Check resources
   → Reads resource://v0_prompting_guide
   → Learns that V0 needs natural language, not code specs
   
   Step 2: Use prompts for specific guidance  
   → Calls v0_enhanced_examples(use_case="dashboard")
   → Gets dashboard-specific examples
   
   Step 3: Make informed tool call
   → Uses natural language prompt based on guidance
   → Avoids technical specifications
   ```

### FastMCP Reference Links (for additional context if needed):

**Getting Started:**
- Installation: https://gofastmcp.com/getting-started/installation.md
- Quickstart: https://gofastmcp.com/getting-started/quickstart.md  
- Welcome: https://gofastmcp.com/getting-started/welcome.md

**Core Server Features:**
- Server: https://gofastmcp.com/servers/server.md
- Tools: https://gofastmcp.com/servers/tools.md
- Resources: https://gofastmcp.com/servers/resources.md
- Prompts: https://gofastmcp.com/servers/prompts.md
- Context: https://gofastmcp.com/servers/context.md
- Logging: https://gofastmcp.com/servers/logging.md
- Progress: https://gofastmcp.com/servers/progress.md
- Sampling: https://gofastmcp.com/servers/sampling.md
- Elicitation: https://gofastmcp.com/servers/elicitation.md

**Authentication & Security:**
- Bearer Auth: https://gofastmcp.com/servers/auth/bearer.md
- Client Bearer: https://gofastmcp.com/clients/auth/bearer.md
- OAuth: https://gofastmcp.com/clients/auth/oauth.md

**Advanced Features:**
- Middleware: https://gofastmcp.com/servers/middleware.md
- Composition: https://gofastmcp.com/servers/composition.md
- OpenAPI: https://gofastmcp.com/servers/openapi.md
- Proxy: https://gofastmcp.com/servers/proxy.md

**Deployment & Integration:**
- Running Server: https://gofastmcp.com/deployment/running-server.md
- ASGI Integration: https://gofastmcp.com/deployment/asgi.md
- Claude Code: https://gofastmcp.com/integrations/claude-code.md
- Claude Desktop: https://gofastmcp.com/integrations/claude-desktop.md
- Cursor: https://gofastmcp.com/integrations/cursor.md
- OpenAI API: https://gofastmcp.com/integrations/openai.md
- Anthropic API: https://gofastmcp.com/integrations/anthropic.md
- Gemini SDK: https://gofastmcp.com/integrations/gemini.md
- ChatGPT: https://gofastmcp.com/integrations/chatgpt.md

**Development Patterns:**
- CLI: https://gofastmcp.com/patterns/cli.md
- Testing: https://gofastmcp.com/patterns/testing.md
- Decorating Methods: https://gofastmcp.com/patterns/decorating-methods.md
- HTTP Requests: https://gofastmcp.com/patterns/http-requests.md
- Tool Transformation: https://gofastmcp.com/patterns/tool-transformation.md

**Tutorials:**
- Create MCP Server: https://gofastmcp.com/tutorials/create-mcp-server.md
- MCP Overview: https://gofastmcp.com/tutorials/mcp.md
- REST API: https://gofastmcp.com/tutorials/rest-api.md

**Client Operations:**
- Client: https://gofastmcp.com/clients/client.md
- Tools: https://gofastmcp.com/clients/tools.md
- Resources: https://gofastmcp.com/clients/resources.md
- Prompts: https://gofastmcp.com/clients/prompts.md
- Transports: https://gofastmcp.com/clients/transports.md
- Logging: https://gofastmcp.com/clients/logging.md
- Progress: https://gofastmcp.com/clients/progress.md
- Sampling: https://gofastmcp.com/clients/sampling.md
- Elicitation: https://gofastmcp.com/clients/elicitation.md
- Roots: https://gofastmcp.com/clients/roots.md
- Messages: https://gofastmcp.com/clients/messages.md

### Core FastMCP Implementation Templates

#### Essential Imports
```python
#!/usr/bin/env python3
import os
import logging
from typing import Dict, Any, List, Optional
from datetime import datetime
from fastmcp import FastMCP
from fastmcp.server.context import Context

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)
```

#### Server Initialization
```python
# Initialize FastMCP server
mcp = FastMCP("Server Name")
```

#### Tool Creation Patterns

##### Standalone Tools (for simple tools that don't call other tools)
```python
@mcp.tool()
async def example_tool(
    param1: str,
    param2: Optional[int] = None,
    ctx: Optional[Context] = None
) -> Dict[str, Any]:
    """
    Tool description here
    
    Args:
        param1: Required string parameter
        param2: Optional integer parameter
        ctx: Context for logging/progress
    
    Returns:
        Result dictionary
    """
    try:
        if ctx:
            await ctx.info(f"Processing {param1}")
            
        # Tool logic here
        result = {
            "success": True,
            "param1": param1,
            "param2": param2,
            "timestamp": datetime.now().isoformat()
        }
        
        if ctx:
            await ctx.info("Tool completed successfully")
            
        return result
        
    except Exception as e:
        logger.error(f"Tool error: {e}")
        if ctx:
            await ctx.error(f"Tool failed: {str(e)}")
        return {
            "success": False,
            "error": str(e)
        }
```

##### Class-Based Tools (for tools that need to call other tools internally)
```python
class ComplexServerTools:
    """
    Class for tools that need to call other tools internally.
    This prevents the 'FunctionTool' object is not callable error.
    
    Pattern from: https://gofastmcp.com/patterns/decorating-methods.md
    """
    
    def __init__(self):
        # Initialize any shared state, clients, or configurations here
        self.shared_client = None  # Example: API clients, database connections
        self.config = {}
    
    async def complex_tool_with_dependencies(
        self,
        param1: str,
        param2: Optional[int] = None,
        ctx: Optional[Context] = None
    ) -> Dict[str, Any]:
        """
        Complex tool that orchestrates multiple operations internally.
        
        This pattern is essential for tools that need to:
        - Call other helper functions
        - Perform multi-step operations
        - Coordinate between different APIs or services
        - Handle complex error recovery
        """
        try:
            if ctx:
                await ctx.info(f"Starting complex processing for {param1}")
            
            # Can call standalone helper functions directly
            validation_result = await validate_input(param1)
            if not validation_result["valid"]:
                return {"success": False, "error": "Invalid input"}
            
            # Can call other class methods internally
            processed_data = await self.process_data(param1, param2)
            
            # Can orchestrate multiple operations
            final_result = await self.combine_results(processed_data, validation_result)
            
            if ctx:
                await ctx.info("Complex tool completed successfully")
                
            return {
                "success": True,
                "result": final_result,
                "metadata": {
                    "processed_at": datetime.now().isoformat(),
                    "operations": ["validate", "process", "combine"]
                }
            }
            
        except Exception as e:
            logger.error(f"Complex tool error: {e}")
            if ctx:
                await ctx.error(f"Complex tool failed: {str(e)}")
            return {"success": False, "error": str(e)}
    
    async def process_data(self, data: str, modifier: Optional[int]) -> Dict[str, Any]:
        """Internal method for data processing"""
        return {
            "processed_data": data.upper(),
            "modifier_applied": modifier or 1,
            "timestamp": datetime.now().isoformat()
        }
    
    async def combine_results(self, processed: Dict, validation: Dict) -> Dict[str, Any]:
        """Internal method for combining operation results"""
        return {
            "combined": True,
            "processed": processed,
            "validation": validation
        }

# Helper function (not decorated, can be called by class methods)
async def validate_input(input_data: str) -> Dict[str, Any]:
    """Standalone helper function for validation"""
    return {
        "valid": len(input_data) > 0,
        "length": len(input_data)
    }

# Create instance and register class methods with decorator
complex_tools = ComplexServerTools()
mcp.tool(complex_tools.complex_tool_with_dependencies)
```

##### Hybrid Pattern Registration (CRITICAL for avoiding FunctionTool errors)
```python
# ===================================================================
# STANDALONE TOOLS (simple tools that don't call other tools)
# ===================================================================
# These tools work perfectly with @mcp.tool() decorator

@mcp.tool()
async def simple_data_operation(table: str, id: str) -> Dict[str, Any]:
    """Simple tool that performs a single operation"""
    # Direct database/API call without calling other decorated tools
    result = await database_client.get(table, id)
    return {"success": True, "data": result}

@mcp.tool()
async def basic_validation(input_data: str) -> Dict[str, Any]:
    """Basic validation tool"""
    return {"valid": len(input_data) > 0, "length": len(input_data)}

# ===================================================================
# CLASS-BASED TOOLS (complex tools that call other tools)
# ===================================================================
# CRITICAL: Use this pattern to avoid 'FunctionTool' object is not callable

class ComplexOperations:
    """
    For tools that need to orchestrate multiple operations.
    This is the ONLY way to avoid FunctionTool errors when tools call other tools.
    """
    
    async def multi_step_operation(
        self, 
        primary_data: str, 
        secondary_data: str
    ) -> Dict[str, Any]:
        """Tool that coordinates multiple operations"""
        
        # ✅ CAN call non-decorated helper functions
        validation = await helper_validate_data(primary_data)
        
        # ✅ CAN call other class methods
        processed = await self.process_internal(secondary_data)
        
        # ❌ CANNOT call @mcp.tool() decorated functions directly
        # This would cause 'FunctionTool' object is not callable error
        
        return {
            "success": True,
            "validation": validation,
            "processed": processed
        }
    
    async def process_internal(self, data: str) -> Dict[str, Any]:
        """Internal processing method"""
        return {"processed": data.upper()}

# Helper functions (NOT decorated, can be called by class methods)
async def helper_validate_data(data: str) -> Dict[str, Any]:
    """Non-decorated helper function"""
    return {"valid": bool(data), "length": len(data)}

# Register class methods with mcp.tool()
complex_ops = ComplexOperations()
mcp.tool(complex_ops.multi_step_operation)
```

#### CRITICAL Pattern Rules:

1. **Simple tools → @mcp.tool() decorator directly**
2. **Complex tools → Class methods + mcp.tool(instance.method)**
3. **Never call decorated tools from decorated tools**
4. **Use helper functions (not decorated) for shared logic**

#### Resource Creation Patterns (CRITICAL - Fixed Syntax)
```python
# CORRECT: Single URI parameter for @mcp.resource
@mcp.resource("resource://config")
def get_config() -> Dict[str, Any]:
    """Server configuration resource"""
    return {
        "version": "1.0",
        "name": "Server Name",
        "features": ["tools", "resources", "prompts"]
    }

# For async resources (like reading files)
@mcp.resource("resource://documentation")
async def get_documentation() -> str:
    """Read documentation from file"""
    doc_path = os.path.join(os.path.dirname(__file__), '..', 'docs', 'guide.md')
    if os.path.exists(doc_path):
        with open(doc_path, 'r') as f:
            return f.read()
    return "Documentation not found"

# Dynamic resource template
@mcp.resource("data://{category}/{item}")
def get_data_item(category: str, item: str) -> Dict[str, Any]:
    """
    Get data item by category and item ID
    
    Args:
        category: Data category
        item: Item identifier
    """
    return {
        "category": category,
        "item": item,
        "data": f"Data for {category}/{item}",
        "timestamp": datetime.now().isoformat()
    }

# WRONG: Don't use multiple parameters
# @mcp.resource("resource://test", "text/plain", "description")  # ❌
```

#### Prompt Creation Patterns (CRITICAL - Fixed Syntax)
```python
# CORRECT: Use @mcp.prompt WITH parentheses (), regular functions (not async)
@mcp.prompt()
def analyze_prompt(topic: str, context: str = "") -> str:
    """
    Generate analysis prompt for given topic
    
    Args:
        topic: Topic to analyze
        context: Additional context
    """
    base_prompt = f"Please analyze the following topic: {topic}"
    if context:
        base_prompt += f"\n\nAdditional context: {context}"
    return base_prompt

# More examples with parameters
@mcp.prompt()
def implementation_guide(feature_type: str, technology: str = "React") -> str:
    """Guide for implementing specific features"""
    return f"""
# Implementation Guide for {feature_type} using {technology}

## Overview
This guide helps you implement {feature_type} with best practices.

## Key Considerations:
1. Architecture patterns for {feature_type}
2. {technology}-specific optimizations
3. Common pitfalls to avoid
4. Testing strategies

## Step-by-Step Instructions:
[Detailed steps based on feature_type and technology]
"""

# WRONG: Don't use async or parentheses
# @mcp.prompt()  # ✅ WITH parentheses
# async def bad_prompt() -> str:  # ❌ No async
```

#### Context Usage Examples (Advanced Features)
```python
# The Context object provides powerful capabilities:

# 1. LOGGING - Send log messages to the client
@mcp.tool
async def process_data(ctx: Context, data: str) -> str:
    """Process data with detailed logging"""
    await ctx.debug("Starting data processing")
    await ctx.info(f"Processing {len(data)} bytes of data")
    
    try:
        # Process the data
        result = await heavy_computation(data)
        await ctx.info("Processing completed successfully")
        return result
    except ValidationError as e:
        await ctx.warning(f"Validation issue: {e}")
        raise
    except Exception as e:
        await ctx.error(f"Processing failed: {str(e)}")
        raise

# 2. PROGRESS REPORTING - Update client on long-running operations
@mcp.tool
async def batch_process(ctx: Context, items: list[str]) -> str:
    """Process multiple items with progress tracking"""
    results = []
    total = len(items)
    
    for i, item in enumerate(items):
        # Report progress to the client
        await ctx.report_progress(progress=i, total=total)
        
        # Process individual item
        result = await process_item(item)
        results.append(result)
        
        # Log progress
        await ctx.info(f"Processed item {i+1}/{total}")
    
    # Final progress update
    await ctx.report_progress(progress=total, total=total)
    return f"Successfully processed {total} items"

# 3. SAMPLING - Request LLM to generate text
@mcp.tool
async def generate_content(ctx: Context, topic: str, style: str = "formal") -> str:
    """Generate content using the client's LLM"""
    # Request LLM generation
    result = await ctx.sample(
        prompt=f"Write a {style} article about {topic}. Include key points and a conclusion.",
        max_tokens=1000
    )
    
    # Handle the response
    if result.type == "content":
        generated_text = result.content.text
        await ctx.info(f"Generated {len(generated_text)} characters of content")
        return generated_text
    else:
        await ctx.error(f"Sampling failed: {result.type}")
        raise ValueError(f"Failed to generate content: {result.type}")

# 4. ELICITATION - Request input from user
from dataclasses import dataclass
from typing import Literal

@dataclass
class ProjectConfig:
    name: str
    framework: Literal["react", "vue", "angular", "svelte"]
    typescript: bool
    features: list[str]

@mcp.tool
async def create_project_interactive(ctx: Context) -> str:
    """Create project with user interaction"""
    # Request structured project configuration
    config_result = await ctx.elicit(
        "Please provide project configuration:",
        response_type=ProjectConfig
    )
    
    if config_result.action == "accept":
        config = config_result.data
        await ctx.info(f"Creating {config.framework} project: {config.name}")
        
        # Create the project
        result = await setup_project(config)
        return f"Created project '{config.name}' with {len(config.features)} features"
        
    elif config_result.action == "decline":
        await ctx.info("User declined to provide configuration")
        return "Project creation skipped"
        
    else:  # cancel
        await ctx.warning("Project creation cancelled by user")
        return "Project creation cancelled"

# 5. MULTI-STEP ELICITATION - Progressive user interaction
@mcp.tool
async def guided_setup(ctx: Context) -> str:
    """Guide user through multi-step setup process"""
    
    # Step 1: Get project name
    name_result = await ctx.elicit(
        "What would you like to name your project?",
        response_type=str
    )
    if name_result.action != "accept":
        return "Setup cancelled"
    project_name = name_result.data
    
    # Step 2: Choose framework
    framework_result = await ctx.elicit(
        f"Which framework for '{project_name}'?",
        response_type=["react", "vue", "angular", "svelte"]
    )
    if framework_result.action != "accept":
        return "Setup cancelled"
    framework = framework_result.data
    
    # Step 3: Confirm TypeScript
    ts_result = await ctx.elicit(
        "Would you like to use TypeScript?",
        response_type=None  # Simple yes/no
    )
    use_typescript = ts_result.action == "accept"
    
    # Log the setup
    await ctx.info(f"Setting up {framework} project '{project_name}' (TypeScript: {use_typescript})")
    
    # Create the project
    return f"Created {framework} project '{project_name}' with{'out' if not use_typescript else ''} TypeScript"

# 6. PATTERN MATCHING WITH ELICITATION
from fastmcp.server.elicitation import (
    AcceptedElicitation, 
    DeclinedElicitation, 
    CancelledElicitation,
)

@mcp.tool
async def smart_assistant(ctx: Context, task: str) -> str:
    """Smart assistant using pattern matching"""
    # Ask for confirmation with details
    result = await ctx.elicit(
        f"Should I proceed with: {task}?",
        response_type=str  # Optional: ask for additional notes
    )
    
    match result:
        case AcceptedElicitation(data=notes) if notes:
            await ctx.info(f"Proceeding with task. Notes: {notes}")
            return f"Completed: {task} (with notes: {notes})"
            
        case AcceptedElicitation():
            await ctx.info("Proceeding with task")
            return f"Completed: {task}"
            
        case DeclinedElicitation():
            await ctx.info("Task declined by user")
            return "Task not executed"
            
        case CancelledElicitation():
            await ctx.warning("Task cancelled by user")
            return "Task cancelled"
```

#### Server Execution Pattern
```python
if __name__ == "__main__":
    # Get port from environment or use default
    port = int(os.getenv('SERVER_NAME_MCP_PORT', '8030'))
    
    # Get API key if needed
    api_key = os.getenv('SERVER_NAME_API_KEY')
    if not api_key:
        logger.warning("No API key found - some features may be limited")
    
    logger.info(f"Starting Server Name MCP Server on port {port}")
    
    # Run with streamable-http transport for OpenAI Responses API compatibility
    mcp.run(transport="streamable-http", host="0.0.0.0", port=port, path="/")
```
#### README Template
```markdown
# {Server Name} HTTP MCP Server

{Description}

## Features

- Multiple tools for {functionality}
- Resources for data access
- Prompts for LLM interactions
- Context-aware logging and progress

## Server Organization

The server is organized into clear sections:

### 🛠️ Tools (4+ main tools)
- **Primary Function**: Tool description
- **Secondary Function**: Tool description
- **Configuration**: Tool description
- **Generation**: Tool description

### 📚 Resources (5+ resource endpoints)
- **Templates**: Component specifications and properties
- **Configuration**: Settings and customization options
- **Patterns**: Best practices and guidelines
- **Examples**: Usage examples with implementations
- **Best Practices**: Development standards

### 💡 Prompts (5-7 specialized prompts)
- **Core Development**: Primary functionality prompts
- **Advanced Features**: Specialized functionality prompts
- **Integration**: Technology integration prompts
- **Performance**: Optimization prompts
- **Quality Assurance**: Testing and validation prompts

## Setup

1. Install dependencies:
   ```bash
   pip install -r requirements.txt
   ```

2. Set environment variables:
   ```bash
   export SERVER_NAME_API_KEY=your_api_key  # Optional
   export SERVER_NAME_MCP_PORT=8030         # Optional
   ```

3. Run the server:
   ```bash
   python src/{server_name}_server.py
   ```

## Usage with Claude

1. Add to Claude:
   ```bash
   claude mcp add --transport http {server-name}-http http://localhost:8030
   ```

2. Use tools:
   - List: `/mcp`
   - Execute: `/mcp__{server_name}__tool_name "arg1" "arg2"`

3. Access resources:
   ```bash
   /mcp_resource server://templates
   /mcp_resource server://examples/{type}
   ```
```

---

## Build Instructions

Extract server details:
```bash
echo "Building server for: $ARGUMENTS"
```

Create directory structure:
```bash
SERVER_NAME=$(echo "$ARGUMENTS" | awk '{print $1}' | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]/-/g')
mkdir -p servers/http/${SERVER_NAME}-http-mcp/src
echo "Created: servers/http/${SERVER_NAME}-http-mcp/"
```

Now create the complete FastMCP server using the templates above:
1. Generate main server file with FastMCP initialization, tools, resources, prompts, and HTTP transport
2. Create requirements.txt with all dependencies
3. Create README.md with setup instructions
4. Create .env.example with environment variables

Use the templates above and reference documentation links for additional context as needed. Customize for the specific server requirements from $ARGUMENTS.

---

## Validation & Self-Correction

After building the server, validate its structure:

```bash
bash skills/mcp-development/scripts/validate-server.sh servers/http/${SERVER_NAME}-http-mcp
```

If validation finds issues, auto-fix them:

```bash
bash skills/mcp-development/scripts/fix-server.sh servers/http/${SERVER_NAME}-http-mcp
```

The validation scripts check:
- ✅ Server entry point exists (server.py or __main__.py)
- ✅ FastMCP import present
- ✅ MCP instance creation
- ✅ Server run call
- ✅ Dependency file exists (pyproject.toml or requirements.txt)
- ✅ FastMCP in dependencies
- ✅ README.md documentation

The fix scripts automatically correct common issues like:
- Missing requirements.txt
- Missing FastMCP dependency
- Missing README.md
- Missing FastMCP imports

This self-correcting pattern ensures every MCP server meets quality standards without AI token usage for pattern recognition.

## Key Requirements for Complete Servers

Based on MUI server development, ensure every FastMCP server includes:

### ✅ Minimum Requirements:
- **5-7 specialized prompts** (not just generic ones)
- **4+ main tools** with clear categorization
- **5+ resource endpoints** for templates, examples, best practices
- **Clear code organization** with section headers and comments
- **Comprehensive documentation** with server organization structure
- **Environment configuration** with .env.example file
- **Type safety** with proper typing imports (avoid unused imports)

### 📋 Code Organization Pattern:
```python
# ===================================================================
# CONFIGURATION & INITIALIZATION
# ===================================================================
# Server setup, imports, clients, helper functions

# ===================================================================
# STANDALONE TOOLS (simple tools that don't call other tools)
# ===================================================================
# Use @mcp.tool() decorator directly

# ===================================================================
# CLASS-BASED TOOLS (complex tools that call other tools)
# ===================================================================
# Use class methods to avoid 'FunctionTool' object is not callable error

class ToolsClass:
    async def complex_tool(self, ...):
        # Can call other functions/methods internally
        pass

# Register class methods
tools_instance = ToolsClass()
mcp.tool(tools_instance.complex_tool)

# ===================================================================
# RESOURCES
# ===================================================================

# ===================================================================
# PROMPTS
# ===================================================================

# ===================================================================
# SERVER EXECUTION
# ===================================================================
if __name__ == "__main__":
    port = int(os.getenv("PORT", 8030))
    # Run with streamable-http transport for OpenAI Responses API compatibility
    mcp.run(transport="streamable-http", host="0.0.0.0", port=port, path="/")
```

### 🎯 Documentation Structure:
- Server Organization section with emojis
- Tools categorized by function (Generation, Configuration, etc.)
- Resources with clear descriptions
- All prompts documented with parameters
- Complete usage examples with resource access

## 📚 Complete Example: Server with Agent-Guiding Prompts & Resources

Here's a complete example showing how to build prompts and resources that guide agents BEFORE they make tool calls:

```python
#!/usr/bin/env python3
import os
import logging
from typing import Dict, Any, List, Optional
from datetime import datetime
from fastmcp import FastMCP
from fastmcp.server.context import Context

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Initialize FastMCP server
mcp = FastMCP("Example API Integration Server")

# ===================================================================
# CRITICAL RESOURCES - Agents should read these FIRST
# ===================================================================

@mcp.resource("resource://usage_guide")
def usage_guide() -> str:
    """CRITICAL: How to use this server correctly"""
    return """
# Example API Server Usage Guide

## 🚨 CRITICAL: Read This Before Making Tool Calls!

This server integrates with ExampleAPI. Before using any tools:

1. **Authentication**: All tools require valid API credentials
2. **Rate Limits**: 100 requests per minute
3. **Data Format**: Use JSON for all requests
4. **Error Handling**: Check response.success before using data

## Tool Categories:

### Data Operations (CRUD)
- create_item: Creates new items
- read_item: Retrieves existing items
- update_item: Modifies items
- delete_item: Removes items

### Batch Operations
- batch_create: Create multiple items
- batch_update: Update multiple items

## Common Patterns:

### Creating Items:
```python
result = await create_item(
    name="Example Item",
    category="test",
    metadata={"key": "value"}
)
```

### Error Handling:
```python
if not result["success"]:
    # Handle error appropriately
    logger.error(f"Failed: {result['error']}")
```

## Best Practices:
1. Always validate input before API calls
2. Use batch operations for multiple items
3. Implement exponential backoff for retries
4. Log all operations for debugging
"""

@mcp.resource("resource://api_examples")
def api_examples() -> str:
    """Concrete examples of API usage"""
    return """
# API Usage Examples

## Example 1: Creating a Product
```python
product = await create_item(
    name="Premium Widget",
    category="electronics",
    metadata={
        "price": 99.99,
        "sku": "WDG-001",
        "inventory": 50
    }
)
```

## Example 2: Batch Update
```python
updates = [
    {"id": "123", "changes": {"price": 89.99}},
    {"id": "456", "changes": {"inventory": 25}}
]
result = await batch_update(items=updates)
```

## Example 3: Complex Query
```python
results = await search_items(
    category="electronics",
    min_price=50,
    max_price=200,
    in_stock=True
)
```
"""

# ===================================================================
# PROMPTS - Dynamic guidance based on use case
# ===================================================================

@mcp.prompt()
def implementation_guide(operation_type: str, data_type: str = "item") -> str:
    """Get specific guidance for implementing operations"""
    guides = {
        "create": f"""
To create a new {data_type}, follow these steps:

1. Validate all required fields
2. Check for duplicates if needed
3. Call create_item with proper structure
4. Handle the response appropriately
5. Log the operation for audit trail

Required fields for {data_type}:
- name (string, non-empty)
- category (string, from allowed list)
- metadata (object, type-specific fields)
""",
        "search": f"""
To search for {data_type} items effectively:

1. Use specific filters to narrow results
2. Implement pagination for large datasets
3. Consider using batch operations
4. Cache results when appropriate
5. Handle empty results gracefully

Search parameters for {data_type}:
- category (filter by type)
- date_range (created/updated timestamps)
- status (active/inactive/archived)
- custom metadata fields
"""
    }
    
    return guides.get(operation_type, f"General guide for {operation_type} on {data_type}")

@mcp.prompt()
def error_handling_guide(error_type: str) -> str:
    """Get guidance for handling specific errors"""
    return f"""
# Error Handling Guide for {error_type}

## Common {error_type} Errors:

1. **Authentication Errors**:
   - Check API key validity
   - Ensure proper headers
   - Verify permissions

2. **Validation Errors**:
   - Review required fields
   - Check data types
   - Validate constraints

3. **Rate Limit Errors**:
   - Implement backoff strategy
   - Use batch operations
   - Cache when possible

## Recovery Strategies:
- Retry with exponential backoff
- Log detailed error information
- Provide user-friendly messages
- Implement circuit breakers
"""

# ===================================================================
# TOOLS - Now agents know how to use these properly
# ===================================================================

@mcp.tool()
async def create_item(
    name: str,
    category: str,
    metadata: Dict[str, Any],
    ctx: Optional[Context] = None
) -> Dict[str, Any]:
    """
    Create a new item in the system.
    
    IMPORTANT: Read resource://usage_guide before using this tool!
    
    Args:
        name: Item name (required, non-empty)
        category: Item category (must be from allowed list)
        metadata: Additional item data
        ctx: Context for logging
    """
    # Tool implementation here
    pass
```

### Key Patterns for Agent Guidance:

1. **Resources provide static documentation** that agents read first
2. **Prompts provide dynamic, parameterized guidance** based on context
3. **Tool docstrings reference resources** to remind agents
4. **Clear categorization** helps agents find the right tool
5. **Examples in resources** show concrete usage patterns

This ensures agents understand HOW to use your server before they start making tool calls!