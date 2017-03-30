defmodule Zeus.Resources.Permission do
  use Zeus.DSL.Resource

  action :evaluate, [[:scope, :entity, :instance_ids, :access_rights, :user_guids]] do
    request do
      url = "/permissions/1/applications/#{params[:scope]}/entitites/#{params[:entity]}/sites/#{params[:domain]}"

      body = %{
        userids: params[:user_guids],
        entityinstanceids: params[:instance_ids],
        accessrights: params[:access_rights]
      }

      {Permissions, :POST, url, body}
    end
  end
end
