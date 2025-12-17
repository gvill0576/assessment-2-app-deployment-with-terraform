import json
import boto3

comprehend = boto3.client('comprehend')

def lambda_handler(event, context):
    """
    Analyzes sentiment of text using Amazon Comprehend
    Expected input: { "text": "I love this product!" }
    """
    try:
        # Parse request body
        body = json.loads(event.get('body', '{}'))
        
        # Get text to analyze
        text = body.get('text', '')
        
        if not text:
            return {
                'statusCode': 400,
                'headers': {
                    'Content-Type': 'application/json',
                    'Access-Control-Allow-Origin': '*'
                },
                'body': json.dumps({
                    'error': 'Text parameter is required'
                })
            }
        
        # Call Comprehend to detect sentiment
        response = comprehend.detect_sentiment(
            Text=text,
            LanguageCode='en'
        )
        
        # Extract sentiment data
        sentiment = response['Sentiment']
        scores = response['SentimentScore']
        
        return {
            'statusCode': 200,
            'headers': {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*'
            },
            'body': json.dumps({
                'sentiment': sentiment,
                'scores': {
                    'positive': float(scores['Positive']),
                    'negative': float(scores['Negative']),
                    'neutral': float(scores['Neutral']),
                    'mixed': float(scores['Mixed'])
                },
                'text': text
            })
        }
        
    except Exception as e:
        print(f"Error: {str(e)}")
        return {
            'statusCode': 500,
            'headers': {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*'
            },
            'body': json.dumps({
                'error': 'Internal server error',
                'details': str(e)
            })
        }
