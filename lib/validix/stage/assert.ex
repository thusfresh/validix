defmodule Validix.Stage.Assert do
  @behaviour Validix.Stage

  alias Validix.Type


  def run(field, type, value, _opts) do
    if assert(type, value) do
      {:ok, value}
    else
      error = %Validix.Error{
        message: "Invalid #{inspect type} #{inspect value} for field #{inspect field}",
        reason: :bad_type,
        field: field,
        type: type,
        value: value,
      }
      {:error, error}
    end
  end


  defp assert(type, value) do
    parent_type_valid? = case Type.parent_type(type) do
      {:ok, nil} -> true
      {:ok, parent_type} -> assert(parent_type, value)
      :error -> false
    end
    parent_type_valid? and valid?(type, value)
  end


  defp valid?(type, value) do
    case Validix.Type.Core.valid?(type, value) do
      {:ok, valid?} -> valid?
      {:any, pairs} -> Enum.any?(pairs, fn({t, v}) -> assert(t, v) end)
      {:all, pairs} -> Enum.all?(pairs, fn({t, v}) -> assert(t, v) end)
    end
  end

end
