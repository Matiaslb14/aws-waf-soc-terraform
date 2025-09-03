import os, json, gzip, boto3
from io import BytesIO

sns = boto3.client('sns')
TOPIC_ARN = os.environ.get('SNS_TOPIC_ARN')

def handler(event, context):
    records = event.get('Records', [])
    alerts = 0
    for r in records:
        s3 = r.get('s3', {})
        bucket = s3.get('bucket', {}).get('name')
        key = s3.get('object', {}).get('key')
        if not bucket or not key:
            continue
        body = read_s3_object(bucket, key)
        for line in body.splitlines():
            if not line:
                continue
            try:
                obj = json.loads(line)
            except Exception:
                continue
            action = obj.get('action')
            labels = [l.get('name','') for l in obj.get('labels', [])]
            term_rule = obj.get('terminatingRuleId')
            if action == 'BLOCK' or any(x in str(labels).lower() for x in ['sqli', 'xss']):
                msg = {
                    'timestamp': obj.get('timestamp'),
                    'clientIp': obj.get('httpRequest', {}).get('clientIp'),
                    'country': obj.get('httpRequest', {}).get('country'),
                    'uri': obj.get('httpRequest', {}).get('uri'),
                    'httpMethod': obj.get('httpRequest', {}).get('httpMethod'),
                    'action': action,
                    'terminatingRuleId': term_rule,
                    'labels': labels,
                }
                sns.publish(TopicArn=TOPIC_ARN, Subject='AWS WAF Alert', Message=json.dumps(msg, indent=2))
                alerts += 1
    return {'alerts_sent': alerts}

def read_s3_object(bucket, key):
    s3c = boto3.client('s3')
    obj = s3c.get_object(Bucket=bucket, Key=key)
    raw = obj['Body'].read()
    try:
        with gzip.GzipFile(fileobj=BytesIO(raw)) as gz:
            return gz.read().decode('utf-8', errors='ignore')
    except OSError:
        return raw.decode('utf-8', errors='ignore')
