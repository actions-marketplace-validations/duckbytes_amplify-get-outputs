#!/bin/sh -l

set -e

APP_ID=$1
BRANCH=$2
ENV_NAME=
AWS_CLI_OUTPUT=

if [[ -z "$AWS_ACCESS_KEY_ID" ]]; then
  echo "You must provide the AWS_ACCESS_KEY_ID environment variable."
  exit 1
fi

if [[ -z "$AWS_SECRET_ACCESS_KEY" ]]; then
  echo "You must provide the AWS_SECRET_ACCESS_KEY environment variable."
  exit 1
fi

if [[ -z "$AWS_REGION" ]] ; then
  echo "You must provide the AWS_REGION environment variable."
  exit 1
fi

if [[ -z "$APP_ID" ]] ; then
  echo "You must provide the app-id."
  exit 1
fi

if [[ -z "$BRANCH" ]] ; then
  echo "You must provide the branch name."
  exit 1
fi

strip_white_space () {
    echo $1 | tr -d " \t\n\r"
}

get_backend_env_name () {
    local name;
    local aws_output;
    echo "Getting env name"
    aws_output=$(aws amplify get-branch --app-id "$APP_ID" --branch-name "$BRANCH")
    exit_status=$?
    name=$(echo "$aws_output" | jq -r ".branch.backendEnvironmentArn" | awk -F"/" '{print (NF>1)? $NF : ""}')
    echo "$name"
    ENV_NAME="$name"
    return $exit_status
}

get_cli_output () {
    local output;
    echo "Getting backend..."
    output=$(aws amplifybackend get-backend --app-id "$APP_ID" --backend-environment-name "$ENV_NAME")
    exit_status=$?
    AWS_CLI_OUTPUT="$output"
    return $exit_status
}

get_user_pool_id () {
    local userPoolId;
    echo "Getting user pool id" >&2
    userPoolId=$(echo "$AWS_CLI_OUTPUT" | jq -r ".AmplifyMetaConfig" | jq -r ".auth" | jq -r ".[keys[0]].output.UserPoolId")
    exit_status=$?
    echo $(strip_white_space "$userPoolId")
    echo "Got user pool ID $userPoolId" >&2
    return $exit_status
}

get_appsync_id () {
    local apiId;
    echo "Getting api ID" >&2
    apiId=$(echo "$AWS_CLI_OUTPUT" | jq -r ".AmplifyMetaConfig" | jq -r ".api" | jq -r ".[keys[0]].output.GraphQLAPIIdOutput")
    exit_status=$?
    echo $(strip_white_space "$apiId")
    echo "Got API id $apiId" >&2
    return $exit_status
}

get_user_pool_arn () {
    local userPoolArn;
    echo "Getting user pool arn" >&2
    userPoolArn=$(echo "$AWS_CLI_OUTPUT" | jq -r ".AmplifyMetaConfig" | jq -r ".auth" | jq -r ".[keys[0]].output.UserPoolArn")
    exit_status=$?
    echo $(strip_white_space "$userPoolArn")
    echo "Got pool ARN $userPoolArn" >&2
    return $exit_status
}

get_user_pool_client_id () {
    local clientId;
    echo "Getting client ID" >&2
    clientId=$(echo "$AWS_CLI_OUTPUT" | jq -r ".AmplifyMetaConfig" | jq -r ".auth" | jq -r ".[keys[0]].output.AppClientID")
    exit_status=$?
    echo $(strip_white_space "$clientId")
    echo "Got pool client ID $clientId" >&2
    return $exit_status
}

get_bucket () {
    local bucket;
    echo "Getting user bucket" >&2
    bucket=$(echo "$AWS_CLI_OUTPUT" | jq -r ".AmplifyMetaConfig" | jq -r ".storage" | jq -r ".[keys[0]].output.BucketName")
    exit_status=$?
    echo $(strip_white_space "$bucket")
    echo "Got bucket $bucket" >&2
    return $exit_status
}

get_backend_graphql_endpoint () {
    local endpoint;
    local env_name;
    echo "Getting graphql endpoint" >&2
    endpoint=$(aws amplifybackend get-backend --app-id "$APP_ID" --backend-environment-name "$ENV_NAME" | jq -r ".AmplifyMetaConfig" | jq -r ".api.platelet.output.GraphQLAPIEndpointOutput")
    exit_status=$?
    echo $(strip_white_space "$endpoint")
    echo "Got endpoint $endpoint" >&2
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
    appsync_id=$(get_appsync_id)
    client_id=$(get_user_pool_client_id)
    echo "Found graphql endpoint: $graphql_endpoint"
    echo "Found user pool id: $user_pool_id"
    echo "Found user pool arn: $user_pool_arn"
    echo "Found user pool clientId: $client_id"
    echo "Found user bucket: $bucket"
    echo "Found appsync ID: $appsync_id"
    echo "graphql_endpoint=$graphql_endpoint" >> $GITHUB_OUTPUT
    echo "user_pool_id=$user_pool_id" >> $GITHUB_OUTPUT
    echo "user_pool_arn=$user_pool_arn" >> $GITHUB_OUTPUT
    echo "client_id=$client_id" >> $GITHUB_OUTPUT
    echo "bucket_name=$bucket" >> $GITHUB_OUTPUT
    echo "appsync_id=$appsync_id" >> $GITHUB_OUTPUT
    echo "env_name=$ENV_NAME" >> $GITHUB_OUTPUT

}

get_backend_env_name
get_cli_output
echo $(write_output)
