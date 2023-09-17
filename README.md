# teeworlds_rest_client

Headless teeworlds 0.7 client with http rest api server

```
bundle
ruby client.rb

curl -X POST http://localhost:4567/connect -F host=localhost -F port=8303
curl -X POST http://localhost:4567/left -F ticks=200
curl -X POST http://localhost:4567/right -F ticks=600
curl -X POST http://localhost:4567/disconnect
curl -X POST http://localhost:4567/messages -F message='hello world'
curl http://localhost:4567/messages
```

