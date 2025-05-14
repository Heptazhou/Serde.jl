# Serde.jl

Serde is a Julia library for (de)serializing data to/from various formats. The library offers a simple and concise API for defining custom (de)serialization behavior for user-defined types. Inspired by the [serde.rs](https://serde.rs/) Rust library, it supports the following data formats:

```@raw html
<html>
  <body>
    <table>
      <tr><th>Format</th><th><div align=center>JSON</div></th><th><div align=center>TOML</div></th></tr>
      <tr>
        <td>Deserialization</td>
        <td><div align=center>✓</div></td>
        <td><div align=center>✓</div></td>
      </tr>
      <tr>
        <td>Serialization</td>
        <td><div align=center>✓</div></td>
        <td><div align=center>✓</div></td>
      </tr>
    </table>
  </body>
</html>
```

## Installation

To install Serde, simply use the Julia package manager:

```julia
] add Serde
```

## Usage

Let's look at some of the most used cases

### Deserialization

The following is an example of how you can deserialize various formats, like JSON, TOML, Query and CSV into a custom structure `JuliaCon`.
The deserialization process was also modified to correctly process `start_date` and `end_date` by adding the method `Serde.deser`

```julia
using Dates, Serde

struct JuliaCon
    title::String
    start_date::Date
    end_date::Date
end

function Serde.deser(::Type{JuliaCon}, ::Type{Date}, v::String)
    return Dates.Date(v, "yyyy U d")
end

# JSON deserialization
json = """
{
  "title": "JuliaCon 2024",
  "start_date": "2024 July 9",
  "end_date": "2024 July 13"
}
"""

julia> juliacon = deser_json(JuliaCon, json)
JuliaCon("JuliaCon 2024", Date("2024-07-09"), Date("2024-07-13"))

# TOML deserialization
toml = """
title = "JuliaCon 2024"
start_date = "2024 July 9"
end_date = "2024 July 13"
"""

julia> juliacon = deser_toml(JuliaCon, toml)
JuliaCon("JuliaCon 2024", Date("2024-07-09"), Date("2024-07-13"))
```

If you want to see more deserialization options, then take a look at the corresponding [section](pages/extended_de.md) of the documentation

### Serialization

The following example shows how an object `juliacon` of custom type `JuliaCon` can be serialized into various formats, like JSON, TOML, XML, etc.
In that case, all dates will be correctly converted into strings of the required format by overloaded function `ser_type`

```julia
using Dates, Serde

struct JuliaCon
    title::String
    start_date::Date
    end_date::Date
end

juliacon = JuliaCon("JuliaCon 2024", Date(2024, 7, 9), Date(2024, 7, 13))

# JSON serialization
function Serde.SerJson.ser_type(::Type{JuliaCon}, v::Date)
    return Dates.format(v, "yyyy U d")
end

julia> to_json(juliacon) |> print
{"title":"JuliaCon 2024","start_date":"2024 July 9","end_date":"2024 July 13"}

# TOML serialization
function Serde.SerToml.ser_type(::Type{JuliaCon}, v::Date)
    return Dates.format(v, "yyyy-mm-dd")
end

julia> to_toml(juliacon) |> print
title = "JuliaCon 2024"
start_date = "2024-07-09"
end_date = "2024-07-13"
```

If you want to see more serialization options, then take a look at the corresponding [section](pages/extended_ser.md) of the documentation

### User-friendly (de)serialization

That's not all, work is currently underway on macro functionality that allows for more fine-grained and simpler customization of the (de)serialization process.
You can choose from various available decorators that will allow you to unleash all the possibilities of Serde.
For more details, check the [documentation](pages/utils.md#Serde.@serde)

```julia
using Dates, Serde

@serde @default_value @de_name struct JuliaCon
    title::String    | "JuliaCon 2024"   | "title"
    start_date::Date | nothing           | "start"
    end_date::Date   | Date(2024, 7, 24) | "end"
end

function Serde.deser(::Type{JuliaCon}, ::Type{Date}, v::String)
    return Dates.Date(v)
end

json = """{"title": "JuliaCon 2024", "start": "2024-07-22"}"""

julia> juliacon = deser_json(JuliaCon, json)
JuliaCon("JuliaCon 2024", Date("2024-07-22"), Date("2024-07-24"))

julia> to_json(juliacon) |> print
{"title":"JuliaCon 2024","start_date":"2024-07-22","end_date":"2024-07-24"}
```
