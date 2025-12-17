import json
import boto3
import base64

polly = boto3.client('polly')

def lambda_handler(event, context):
    """
    Converts text to speech using Amazon Polly
    Expected input: { "text": "Hello world", "voiceId": "Joanna" }
    """
    try:
        # Parse request body
        body = json.loads(event.get('body', '{}'))
        
        # Get parameters
        text = body.get('text', '')
        voice_id = body.get('voiceId', 'Joanna')
        
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
        
        # Call Polly to synthesize speech
        response = polly.synthesize_speech(
            Text=text,
            OutputFormat='mp3',
            VoiceId=voice_id,
            Engine='neural'
        )
        
        # Read audio stream and encode to base64
        audio_stream = response['AudioStream'].read()
        audio_base64 = base64.b64encode(audio_stream).decode('utf-8')
        
        return {
            'statusCode': 200,
            'headers': {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*'
            },
            'body': json.dumps({
                'audioContent': audio_base64,
                'contentType': 'audio/mpeg'
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
