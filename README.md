# Hosting a Dashboard Application on S3

NASA's [Center for Near Earth Object Studies](https://cneos.jpl.nasa.gov/) maintains a dataset on all asteroids in Earth's proximity. Using [NASA's API](https://api.nasa.gov/), anyone can access data on nearby asteroids on a given date. The website outlined below runs on S3 to extract data from this API and create daily NEO dashbaord.

This website is hosted on an S3 bucket, using its Javascript to make calls to an API hosted on API Gateway. This API in turn triggers a Lambda function that queries the NASA API and stores recently accessed NEO data on a DynamoDB table to speed up subsequent requests. This data is returned to the scripts on the S3 bucket, which use jQuery to create the HTML elements for the dashboard. The website is then distributed using a CloudFront distribution with a Route53 domain. Thanks to the serverless design of this project, maintenance and hosting is cheap and easy, without sacrificing availability.

If you enjoyed visiting the site or have any comments/suggestions, feel free to reach out!
