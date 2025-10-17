# amplify-get-outputs

amplify-get-outputs is a GitHub action to get the graphql endpoint, user pool id, user pool arn and bucket from an Amplify deployment.

Example:

```
- name: Wait for Amplify to finish remote build
  uses: duckbytes/amplify-get-outputs@v1.0
  with:
    app-id: ${{ vars.AMPLIFY_APP_ID }}
    env-name: ${{ vars.AMPLIFY_ENV_NAME }}
  env:
    AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
    AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
    AWS_REGION: ${{ secrets.AWS_REGION }}
```

### Inputs

`app-id`, `env-name` are required input. You also must set `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY` and `AWS_REGION` in your environment variables.

### Outputs
- `graphql_endpoint` # The GraphQL endpoint.
- `user_pool_id` # The user pool id.
- `user_pool_arn` # The user pool ARN.

You can access these values later in your workflow like this:

`${{ steps.amplify_status.outputs.graphql_endpoint }}`
