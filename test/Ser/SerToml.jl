# Ser/SerToml

@testset verbose = true "SerToml" begin
    @testset "Case №1: Dict to Toml" begin
        exp_kvs = ODict(
            "bar" => "test",
            "foo" => ODict(
                "baz" => "exp_kvsi",
                "conf" => ODict(
                    "boo" => "aaa",
                    "monf" => ODict("abbr" => "ppp", "mint" => "coconut"),
                    "tonf" => ODict("aqua" => "cyan"),
                ),
            ),
        )
        exp_str = """
        bar = "test"

        [foo]
        baz = "exp_kvsi"

        \t[foo.conf]
        \tboo = "aaa"

        \t\t[foo.conf.monf]
        \t\tabbr = "ppp"
        \t\tmint = "coconut"

        \t\t[foo.conf.tonf]
        \t\taqua = "cyan"
        """
        @test Serde.to_toml(exp_kvs) == exp_str

        exp_kvs = ODict(
            "bar" => "test",
            "foo" => ODict(
                "baz" => :exp_kvsi,
                :conf => ODict(
                    "boo" => "aaa",
                    "monf" => ODict("abbr" => "ppp", "mint" => "coconut"),
                    "tonf" => ODict("aqua" => "cyan"),
                ),
            ),
        )
        @test Serde.to_toml(exp_kvs) == exp_str

        exp_kvs = ODict(
            "bar" => "test",
            123_456 => ODict(
                "baz" => :exp_kvsi,
                :conf => ODict(
                    "boo" => "aaa",
                    "monf" => ODict("abbr" => "ppp", "mint" => true),
                    "tonf" => ODict("aqua" => "cyan"),
                ),
            ),
        )
        exp_str = """
        bar = "test"

        [123456]
        baz = "exp_kvsi"

        \t[123456.conf]
        \tboo = "aaa"

        \t\t[123456.conf.monf]
        \t\tabbr = "ppp"
        \t\tmint = true

        \t\t[123456.conf.tonf]
        \t\taqua = "cyan"
        """
        @test Serde.to_toml(exp_kvs) == exp_str
    end

    @testset "Case №2: Struct to Toml" begin
        struct Bar1
            v1::Int64
            v2::String
        end

        struct Bar2
            v1::Int64
            v2::String
        end

        struct Fooo
            val::Int64
            bar1::Bar1
            bar2::Vector{Bar2}
            uuid::UUID
        end

        Serde.SerToml.ser_name(::Type{Fooo}, ::Val{:val}) = :test
        Serde.SerToml.ser_value(::Type{Fooo}, ::Val{:bar1}, x::Bar1) = 1

        exp_str = """
        test = 100
        bar1 = 1
        uuid = "f47ac10b-58cc-4372-a567-0e02b2c3d479"

        [[bar2]]
        v1 = 100
        v2 = "ds"

        [[bar2]]
        v1 = 100
        v2 = "ds"
        """
        @test Serde.to_toml(
            Fooo(
                100,
                Bar1(100, "ds"),
                [Bar2(100, "ds"), Bar2(100, "ds")],
                UUID("f47ac10b-58cc-4372-a567-0e02b2c3d479"),
            ),
        ) == exp_str

        exp_str = """
        test = 100
        bar1 = 1
        bar2 = []
        uuid = "f47ac10b-58cc-4372-a567-0e02b2c3d479"
        """
        @test Serde.to_toml(
            Fooo(
                100,
                Bar1(100, "ds"),
                [],
                UUID("f47ac10b-58cc-4372-a567-0e02b2c3d479"),
            ),
        ) == exp_str
    end

    @testset "Case №3: Vectors witexp_kvs mixed types" begin
        struct BarToml3
            a::Int64
            d::String
        end

        exp_str = """

        [[key]]
        a = 100
        d = "ds"

        [[key]]
        name = "imya"
        age = 1
        """

        @test Serde.to_toml(ODict("key" => [1, 2.2, "d"])) == "key = [1,2.2,\"d\"]\n"
        @test Serde.to_toml(
            ODict("key" => [BarToml3(100, "ds"), ODict("name" => "imya", "age" => 1)]),
        ) == exp_str

        @test_throws "TomlSerializationError: mix simple and complex types" begin
            Serde.to_toml(ODict("key" => ["1", "2", BarToml3(100, "ds")]))
        end
    end

    @testset "Case №4: Backward compatibility" begin
        toml = """
        variable_dump_dir = "%{DUMP_PATEXP_KVS}%/some_app"
        generator_publisexp_kvser_name = "%{CURRENT_FILE}%"

        [some_config]
        some_server_exp_kvsost = "0.0.0.0"
        some_server_port = 8080

        some_server_refresexp_kvs_token_name = "App"
        some_server_session_timeout = 86400

        \t[[some_config.some_accounts]]
        \tusername = "test1"
        \tpassword = "sexp_kvsa256_79c12fd077a3996fd101b53b211b320acec4003fb"
        \t\t[some_config.some_accounts.role]

        \t[[some_config.some_accounts]]
        \tusername = "test2"
        \tpassword = "sexp_kvsa256_79c12fd077a3996fd101b53b211b320acec4003fb"
        \t\t[some_config.some_accounts.role]
        """

        parsed_toml = Serde.parse_toml(toml)
        reparsed_toml = Serde.parse_toml(Serde.to_toml(parsed_toml))
        @test parsed_toml == reparsed_toml
    end

    @testset "Case №5: Time types" begin
        struct TomlSerFoo5
            first_date::Date
            time::Time
            second_date::DateTime
            nanodate::NanoDate
        end

        struct TomlSerBar
            toml_ser_foo_5::TomlSerFoo5
        end

        function Serde.deser(::Type{TomlSerFoo5}, ::Type{Date}, v::String)
            return Dates.Date(v, "U d, yyyy")
        end

        function Serde.deser(::Type{TomlSerFoo5}, ::Type{NanoDate}, v::String)
            return NanoDate(v)
        end

        toml = """
        [toml_ser_foo_5]
        first_date = "July 13, 2024"
        time = 14:41:59.316
        second_date = 2024-01-23T14:42:14.316Z
        nanodate = "2024-01-23T14:42:14.316366122"
        """

        @test to_toml(deser_toml(TomlSerBar, toml)) == """
        \n[toml_ser_foo_5]
        first_date = 2024-07-13
        time = 14:41:59.316
        second_date = 2024-01-23T14:42:14.316
        nanodate = "2024-01-23T14:42:14.316366122"
        """
    end
end
