# IAM users
resource "aws_iam_user" "user-1" {
  name = "spacex-1"
  tags = {
    Name = "spacex-1"
  }
}

resource "aws_iam_user" "user-2" {
  name = "Aerospace-1"
  tags = {
    Name = "Aerospace-1"
  }
}

# S3 Buckets
resource "aws_s3_bucket" "bucket-1" {
  bucket = "traccs-input103"
  tags = {
    Name = "traccs-input103"
  }
}

resource "aws_s3_bucket" "bucket-2" {
  bucket = "traccs-output103"
  tags = {
    Name = "traccs-output103"
  }
}

# IAM Policies for users to access buckets

resource "aws_iam_policy" "user_1_policy" {
  name        = "user-1-bucket"
  description = "User-1 IAM policy for traccs-input and traccs-output"
  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Action": [
          "s3:Get*",
          "s3:List*",
          "s3:Describe*",
          "s3-object-lambda:Get*",
          "s3-object-lambda:List*"
        ],
        "Resource": "*"
      },
      {
        "Effect": "Allow",
        "Action": [
          "s3:ListAllMyBuckets",
          "s3:ListBucket",
          "s3:GetObject"
        ],
        "Resource": [
          "arn:aws:s3:::traccs-output103",
          "arn:aws:s3:::traccs-output103/*"
        ]
      },
      {
        "Effect": "Deny",
        "Action": "s3:PutObject",
        "Resource": "arn:aws:s3:::traccs-output103/*"
      },
      {
        "Effect": "Allow",
        "Action": [
          "s3:PutObject",
          "s3:GetObject",
          "s3:DeleteObject",
          "s3:ListBucket"
        ],
        "Resource": [
          "arn:aws:s3:::traccs-input103",
          "arn:aws:s3:::traccs-input103/*"
        ]
      }
    ]
  })
}

resource "aws_iam_policy" "user_2_policy" {
  name        = "user-2-bucket"
  description = "User-2 IAM policy for traccs-input and traccs-output"
  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Action": [
          "s3:Get*",
          "s3:List*",
          "s3:Describe*",
          "s3-object-lambda:Get*",
          "s3-object-lambda:List*"
        ],
        "Resource": "*"
      },
      {
        "Effect": "Allow",
        "Action": [
          "s3:ListAllMyBuckets",
          "s3:ListBucket",
          "s3:GetObject"
        ],
        "Resource": [
          "arn:aws:s3:::traccs-input103",
          "arn:aws:s3:::traccs-input103/*"
        ]
      },
      {
        "Effect": "Deny",
        "Action": "s3:PutObject",
        "Resource": "arn:aws:s3:::traccs-input103/*"
      },
      {
        "Effect": "Allow",
        "Action": [
          "s3:PutObject",
          "s3:GetObject",
          "s3:DeleteObject",
          "s3:ListBucket"
        ],
        "Resource": [
          "arn:aws:s3:::traccs-output103",
          "arn:aws:s3:::traccs-output103/*"
        ]
      }
    ]
  })
}

# Attach IAM policies to the users
resource "aws_iam_policy_attachment" "user_1_policy_attachment" {
    name = "user_1_policy_attachment"
    users = [ aws_iam_user.user-1.name ]
    policy_arn = aws_iam_policy.user_1_policy.arn
  
}
resource "aws_iam_policy_attachment" "user_2_policy_attachment" {
  name       = "user-2-policy-attachment"
  users      = [aws_iam_user.user-2.name]
  policy_arn = aws_iam_policy.user_2_policy.arn
}

## SNS

# SNS Topics
resource "aws_sns_topic" "s3_event_notifications" {
  name = "s3_event_notiications"
}

# SNS Topic Policy to allow S3 to publish notifications
resource "aws_sns_topic_policy" "s3_event_policy" {
  arn    = aws_sns_topic.s3_event_notifications.arn
  policy = jsonencode({
    "Version" : "2008-10-17",
    "Id" : "__default_policy_ID",
    "Statement" : [
      {
        "Sid" : "AllowS3Bucket1Publish",
        "Effect" : "Allow",
        "Principal" : {
          "AWS" : "*"
        },
        "Action" : [
          "SNS:Publish",
          "SNS:RemovePermission",
          "SNS:SetTopicAttributes",
          "SNS:DeleteTopic",
          "SNS:ListSubscriptionsByTopic",
          "SNS:GetTopicAttributes",
          "SNS:AddPermission",
          "SNS:Subscribe"
        ],
        "Resource" : aws_sns_topic.s3_event_notifications.arn,
        "Condition" : {
          "ArnEquals" : {
            "aws:SourceArn" : "arn:aws:s3:::${aws_s3_bucket.bucket-1.bucket}"
          }
        }
      },
      {
        "Sid" : "AllowS3Bucket1PublishConsole",
        "Effect" : "Allow",
        "Principal" : {
          "AWS" : "*"
        },
        "Action" : "SNS:Publish",
        "Resource" : aws_sns_topic.s3_event_notifications.arn
      },
      {
        "Sid" : "AllowS3Bucket1SubscribeConsole",
        "Effect" : "Allow",
        "Principal" : {
          "AWS" : "*"
        },
        "Action" : "SNS:Subscribe",
        "Resource" : aws_sns_topic.s3_event_notifications.arn
      },
      {
        "Sid" : "AllowS3Bucket2Publish",
        "Effect" : "Allow",
        "Principal" : {
          "AWS" : "*"
        },
        "Action" : [
          "SNS:Publish",
          "SNS:RemovePermission",
          "SNS:SetTopicAttributes",
          "SNS:DeleteTopic",
          "SNS:ListSubscriptionsByTopic",
          "SNS:GetTopicAttributes",
          "SNS:AddPermission",
          "SNS:Subscribe"
        ],
        "Resource" : aws_sns_topic.s3_event_notifications.arn,
        "Condition" : {
          "ArnEquals" : {
            "aws:SourceArn" : "arn:aws:s3:::${aws_s3_bucket.bucket-2.bucket}"
          }
        }
      },
      {
        "Sid" : "AllowS3Bucket2PublishConsole",
        "Effect" : "Allow",
        "Principal" : {
          "AWS" : "*"
        },
        "Action" : "SNS:Publish",
        "Resource" : aws_sns_topic.s3_event_notifications.arn
      },
      {
        "Sid" : "AllowS3Bucket2SubscribeConsole",
        "Effect" : "Allow",
        "Principal" : {
          "AWS" : "*"
        },
        "Action" : "SNS:Subscribe",
        "Resource" : aws_sns_topic.s3_event_notifications.arn
      }
    ]
  })
}






# SNS subscription for topics
resource "aws_sns_topic_subscription" "s3_event_subscription" {
  topic_arn = aws_sns_topic.s3_event_notifications.arn
  protocol = "email"
  endpoint = "manojgonchal111@gmail.com"
  
}



# bucket notifications

resource "aws_s3_bucket_notification" "bucket1_notification" {
  bucket = aws_s3_bucket.bucket-1.id

  topic {
    topic_arn = aws_sns_topic.s3_event_notifications.arn
    events = ["s3:ObjectCreated:*", "s3:ObjectRemoved:*"]
  }
  
}

resource "aws_s3_bucket_notification" "bucket2_notification" {
  bucket = aws_s3_bucket.bucket-2.id
  topic {
    topic_arn = aws_sns_topic.s3_event_notifications.arn
    events = [ "s3:ObjectCreated:*", "s3:ObjectRemoved:*" ]
  }
  
}
