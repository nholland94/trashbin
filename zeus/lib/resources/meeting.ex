defmodule Zeus.Resources.Meeting do
  use Zeus.DSL.Resource

  full_rest_actions MediaManager, [:id, :guid], "/api/events"

  # relations do
  #   has_one :meeting_type, :guid, :meeting_type_guid
  #   has_one :meeting_status, :id, :meeting_status_id
  # end
end
