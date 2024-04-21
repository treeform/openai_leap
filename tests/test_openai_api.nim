import openai_leap, jsony, std/[unittest, os]

proc dumpHook*(s: var string, v: object) =
  ## jsony skip optional fields that are nil
  s.add '{'
  var i = 0
  # Normal objects.
  for k, e in v.fieldPairs:
    when compiles(e.isSome):
      if e.isSome:
        if i > 0:
          s.add ','
        s.dumpHook(k)
        s.add ':'
        s.dumpHook(e)
        inc i
    else:
      if i > 0:
        s.add ','
      s.dumpHook(k)
      s.add ':'
      s.dumpHook(e)
      inc i
  s.add '}'

const
  TestModel = "gpt-3.5-turbo"
  TestEmbedding = "text-embedding-3-small"
  BaseUrl = "https://api.openai.com/v1"
  #BaseUrl = "http://localhost:11434/v1"

# https://github.com/ollama/ollama/blob/main/docs/openai.md

suite "openai_leap":
  var openai: OpenAIAPI

  setup:
    if BaseUrl == "http://localhost:11434/v1":
      putEnv("OPENAI_API_KEY", "ollama")
    openai = newOpenAIAPI(BaseUrl)
  teardown:
    openai.close()

  suite "models":
    test "list":
      let models = openai.listModels()
      # echo "OpenAI Models:"
      # for m in models:
      #   echo m.id
      echo "Model Count: " & $models.len
    test "get":
      let model = openAI.getModel(TestModel)
      echo toJson(model)
    test "delete":
      echo "TEST NOT IMPLEMENTED"

  suite "embeddings":
    test "create":
      let resp = openai.generateEmbeddings(TestEmbedding, "how are you today?")
      let vec = resp.data[0].embedding
      echo "Embedding Length: " & $vec.len
  suite "completions":
    test "create":
      let system = "Please talk like a pirate. you are Longbeard the Llama."
      let prompt = "How are you today?"
      let resp = openai.createChatCompletion(TestModel, system, prompt)
      echo resp
