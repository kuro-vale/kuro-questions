# kuro-questions

[![PWD](https://raw.githubusercontent.com/play-with-docker/stacks/master/assets/images/button.png)](https://labs.play-with-docker.com/?stack=https://raw.githubusercontent.com/kuro-vale/kuro-questions/main/pwd-stack.yml)

[![Tests](https://github.com/kuro-vale/kuro-questions/actions/workflows/tests.yml/badge.svg)](https://github.com/kuro-vale/kuro-questions/actions/workflows/tests.yml)

API project made with vapor.

The thematic of this API is Questions and Answers.

This API uses JWT as a authentication method

See the API [docs](https://documenter.getpostman.com/view/20195671/2s8YKJBf8c)

[![Run in Postman](https://run.pstmn.io/button.svg)](https://app.getpostman.com/run-collection/20195671-8ddfdd09-7122-4c29-aec4-b78f0f336df7?action=collection%2Ffork&collection-url=entityId%3D20195671-8ddfdd09-7122-4c29-aec4-b78f0f336df7%26entityType%3Dcollection%26workspaceId%3D340d12f8-bfd8-4f84-8bc7-f3b080c24682)

## Deploy

Follow any of these methods and open http://localhost:8080/ to see the API welcome page.

### Docker

Run the command below to quickly deploy this project on your machine, see the [docker image](https://hub.docker.com/r/kurovale/kuro-questions) for more info.

```bash
docker run -d -p 8080:8080 kurovale/kuro-questions:sqlite
```

### Quick Setup

1. create a .env file, use .env.example as reference (Use a postgres database)
2. run ```swift run```
