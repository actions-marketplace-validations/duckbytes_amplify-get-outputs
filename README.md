# amplify-get-outputs

amplify-get-outputs is a GitHub action to get the environment name, graphQL endpoint, graphQL ID, user pool ID, user pool ARN and bucket name from a branch connected Amplify deployment.

Example:

```
- name: Get Amplify outputs
  uses: duckbytes/amplify-get-outputs@v1.0
  id: amplify_status
  with:
    app-id: ${{ vars.AMPLIFY_APP_ID }}
    branch-name: ${{ github.ref_name }}
  env:
    AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
    AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
    AWS_REGION: ${{ vars.AWS_REGION }}
```

### Inputs

`app-id`, `branch-name` are required input. You also must set `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY` and `AWS_REGION` in your environment variables.

### Outputs
- `env_name` # The backend environment name.
- `graphql_endpoint` # The GraphQL endpoint.
- `appsync_id` # The AppSync ID.
- `user_pool_id` # The user pool ID.
- `user_pool_arn` # The user pool ARN.
- `bucket_name` # The storage bucket if used.
- `stack_name` # The cloudformation stack name.
- `deployment_bucket_name` # The deployment bucket name.

You can access these values later in your workflow like this:

`${{ steps.amplify_status.outputs.graphql_endpoint }}`
