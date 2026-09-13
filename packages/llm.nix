{ pkgs }:
pkgs.llm.withPlugins {
  # LLM access to models by Anthropic, including the Claude series <https://github.com/simonw/llm-anthropic>
  llm-anthropic = true;

  # LLM plugin providing access to Deepseek models. <https://github.com/abrasumente233/llm-deepseek>
  llm-deepseek = true;

  # Ask questions of LLM documentation using LLM <https://github.com/simonw/llm-docs>
  llm-docs = true;

  # Debug plugin for LLM <https://github.com/simonw/llm-echo>
  llm-echo = true;

  # LLM plugin to access Google's Gemini family of models <https://github.com/simonw/llm-gemini>
  llm-gemini = true;

  # AI-powered Git commands for the LLM CLI tool <https://github.com/OttoAllmendinger/llm-git>
  llm-git = true;

  # LLM plugin providing access to Grok models using the xAI API <https://github.com/Hiepler/llm-grok>
  llm-grok = true;

  # OpenAI plugin for LLM <https://github.com/simonw/llm-openai-plugin>
  llm-openai-plugin = true;

  # LLM plugin for models hosted by OpenRouter <https://github.com/simonw/llm-openrouter>
  llm-openrouter = true;

}
