#!/bin/sh -l

set -e

APP_ID=$1
ENV_NAME=$2

if [[ -z "$AWS_ACCESS_KEY_ID" ]]; then
  echo "You must provide the AWS_ACCESS_KEY_ID environment variable."
  exit 1
fi

if [[ -z "$AWS_SECRET_ACCESS_KEY" ]]; then
  echo "You must provide the AWS_SECRET_ACCESS_KEY environment variable."
  exit 1
fi

if [[ -z "$AWS_DEFAULT_REGION" ]] ; then
  echo "You must provide the AWS_REGION environment variable."
  exit 1
fi

if [[ -z "$APP_ID" ]] ; then
  echo "You must provide the app-id."
  exit 1
fi

if [[ -z "$ENV_NAME" ]] ; then
  echo "You must provide the env name."
  exit 1
fi

strip_white_space () {
    echo $1 | tr -d " \t\n\r"
}

get_user_pool_id () {
    local userPoolId;
    echo "Getting user pool id" >&2
    userPoolId=$(aws amplifybackend get-backend --app-id "$APP_ID" --backend-environment-name "$ENV_NAME" | jq -r ".AmplifyMetaConfig" | jq -r ".auth" | jq -r ".[keys[0]].output.UserPoolId")
    exit_status=$?
    echo $(strip_white_space "$userPoolId")
    return $exit_status
}


get_user_pool_arn () {
    local userPoolArn;
    echo "Getting user pool arn" >&2
    userPoolArn=$(aws amplifybackend get-backend --app-id "$APP_ID" --backend-environment-name "$ENV_NAME" | jq -r ".AmplifyMetaConfig" | jq -r ".auth" | jq -r ".[keys[0]].output.UserPoolArn")
    exit_status=$?
    echo $(strip_white_space "$userPoolArn")
    return $exit_status
}

get_bucket () {
    local bucket;
    echo "Getting user bucket" >&2
    bucket=$(aws amplifybackend get-backend --app-id "$APP_ID" --backend-environment-name "$ENV_NAME" | jq -r ".AmplifyMetaConfig" | jq -r ".storage" | jq -r ".[keys[0]].output.BucketName")
    exit_status=$?
    echo $(strip_white_space "$bucket")
    return $exit_status
}

get_backend_graphql_endpoint () {
    local endpoint;
    local env_name;
    echo "Getting graphql endpoint" >&2
    endpoint=$(aws amplifybackend get-backend --app-id "$APP_ID" --backend-environment-name "$ENV_NAME" | jq -r ".AmplifyMetaConfig" | jq -r ".api.platelet.output.GraphQLAPIEndpointOutput")
    exit_status=$?
    echo $(strip_white_space "$endpoint")
    return $exit_status
}

write_output () {
    local graphql_endpoint;
    local user_pool_id;
    local user_pool_arn
    graphql_endpoint=$(get_backend_graphql_endpoint)
    user_pool_id=$(get_user_pool_id)
    user_pool_arn=$(get_user_pool_arn)
    bucket=$(get_bucket)
    echo "Found graphql endpoint: $graphql_endpoint"
    echo "Found user pool id: $user_pool_id"
    echo "Found user pool arn: $user_pool_arn"
    echo "Found user bucket: $bucket"
    echo "graphql_endpoint=$graphql_endpoint" >> $GITHUB_OUTPUT
    echo "user_pool_id=$user_pool_id" >> $GITHUB_OUTPUT
    echo "user_pool_arn=$user_pool_arn" >> $GITHUB_OUTPUT
    echo "bucket=$bucket" >> $GITHUB_OUTPUT

}

echo $(write_output)
