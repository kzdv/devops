## Prerequisites

Install [adsf](https://asdf-vm.com/)
Configure your aws-cli credentials with a profile named `zdv`

```
asdf plugin add nodejs
asdf install
npm install -g serverless

# To deploy
serverless deploy

# To manually stop the dev instance
serverless invoke --function stop

# To manually start the dev instance
serverless invoke --function start
```