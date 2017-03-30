defmodule Zeus.Http.Exceptions do
  defmodule BadRequestException do
    defexception [:message]
  end

  defmodule InternalServerErrorException do
    defexception [:message]
  end
end
