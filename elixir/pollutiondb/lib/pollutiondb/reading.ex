defmodule Pollutiondb.Reading do
  use Ecto.Schema
  import Ecto.Query
  alias Pollutiondb.Repo

  schema "readings" do
    field :date, :date
    field :time, :time
    field :type, :string
    field :value, :float

    # Relacja do stacji
    belongs_to :station, Pollutiondb.Station
  end

  # Dodawanie z aktualnym czasem i relacją do stacji
  def add_now(station, type, value) do
    %Pollutiondb.Reading{
      station_id: station.id, # Relacja do przekazanej stacji
      date: Date.utc_today(),
      time: Time.utc_now() |> Time.truncate(:second),
      type: type,
      value: value
    }
    |> Repo.insert()
  end

  # Wersja z jawnym podawaniem daty i czasu (przydatna do parsera)
  def add(station, date, time, type, value) do
    %Pollutiondb.Reading{
      station_id: station.id,
      date: date,
      time: time,
      type: type,
      value: value
    }
    |> Repo.insert()
  end

  # Wyszukiwanie po dacie
  def find_by_date(date) do
    from(r in Pollutiondb.Reading, where: r.date == ^date)
    |> Repo.all()
  end
end