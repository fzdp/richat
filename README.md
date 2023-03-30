# Richat

## A powerful command-line ChatGPT tool.

Richat is a command-line ChatGPT tool implemented in Ruby that supports highly customizable configuration. It can save chat logs, performs fuzzy searches on historical inputs, allows for prompt customization and switching at any time.

https://user-images.githubusercontent.com/6159178/228784846-a31772c0-53a5-4aff-92ae-2e33d9c6fad5.mov

## Installation

```
gem install richat
```

## Usage

There are two ways to configure OpenAI API key

1. set `OPENAI_API_KEY` env variable
2. edit `~/.richat/config.json` file and set API key, for example

```
{
  "chatgpt": {
    "api_key": "YOUR OPENAI API KEY"
  }
}
```

Then run `richat` command to talk with ChatGPT.

<img width="800" alt="image" src="https://user-images.githubusercontent.com/6159178/228755576-5d76a777-f07e-43f6-8141-4f9e19f15372.png">

### Configuration

Use `/config` command to show current configuration.

```
>> /config
Configuration file path is /Users/fzdp/.richat/config.json
{
  "chatgpt": {
    "api_key": "YOUR_OPENAI_API_KEY",
    "model": "gpt-3.5-turbo",
    "temperature": 0.7
  },
  "log": {
    "enable": true,
    "log_dir": "~/.richat/logs",
    "user_role": "USR",
    "ai_role": "GPT",
    "system_role": "SYS"
  },
  "shell": {
    "save_history": true,
    "enable_chat_context": true,
    "show_welcome_info": true,
    "history_file": "~/.richat/shell_history.txt"
  },
  "prompt": {
    "prompt_dir": "~/.richat/prompts",
    "default": ""
  }
}
```

Edit `~/.richat/config.json` if you need customize configuration.

### Chat log

By default, Richat will log your chat history and log names are in date format.

Set `log.enable` to false if you don't need log feature.

<img width="409" alt="" src="https://user-images.githubusercontent.com/6159178/228758657-1dbbe25b-e768-403d-8b42-3b270f53fe2a.png">

### Prompt

You can place prompt files in `~/.richat/prompts` or other directory defined in configure file.

For example, if you place `emoji`, `linux`, `wikipedia` in the directory, then in Richat shell `/prompt` command will show these prompt files.

<img width="960" alt="" src="https://user-images.githubusercontent.com/6159178/228761906-4ab74529-3ccb-41b7-badc-98cc0fd9bd72.png">

#### Change prompt

You can use `/prompt` command to switch prompt, the argument is prompt file name or prompt file index.

<img width="960" alt="" src="https://user-images.githubusercontent.com/6159178/228764026-79bbbfef-cd5d-4641-9edf-91f7d71063a5.png">

#### Set default prompt

For example if you want to use linux as default prompt, just edit config file

```json
{
  "prompt": {
    "default": "linux"
  }
}
```

Then Richat shell will use linux prompt when it's run

<img width="960" alt="" src="https://user-images.githubusercontent.com/6159178/228766064-12230d33-158a-413e-8473-6a7dc60f28bd.png">

### Input history 

By default your input history will be saved in `~/.richat/shell_history_file`.

In Richat shell mode, there are three ways to enhance chat experience.

1. press TAB to auto complete input
2. press Arrow keys to traverse history
3. press `Control + R` to fuzzy search input

### Stream mode

ChatGPT stream mode is auto enabled in Richat shell mode

https://user-images.githubusercontent.com/6159178/228770757-c3e1c286-7077-4a00-b376-a491ca280126.mov

### Cli

You can run `richat` with additional chat content directly

```
~ richat hello world
Hello! How can I assist you today?
```

### Chat context

Chat context is enabled by default, because ChatGPT have no memory of past requests, all relevant information must be supplied via the conversation.

You can turn it off in config file.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/fzdp/richat.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

