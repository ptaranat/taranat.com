-module(taranat_dev_ffi).
-export([serve/2]).

serve(Port, DocRoot) ->
    inets:start(),
    Config = [
        {port, Port},
        {server_name, "taranat-dev"},
        {server_root, "."},
        {document_root, binary_to_list(DocRoot)},
        {bind_address, {127, 0, 0, 1}},
        {directory_index, ["index.html"]},
        {mime_types, [
            {"html", "text/html; charset=utf-8"},
            {"css", "text/css; charset=utf-8"},
            {"js", "text/javascript; charset=utf-8"},
            {"mjs", "text/javascript; charset=utf-8"},
            {"json", "application/json"},
            {"webmanifest", "application/manifest+json"},
            {"xml", "application/xml"},
            {"txt", "text/plain; charset=utf-8"},
            {"svg", "image/svg+xml"},
            {"png", "image/png"},
            {"jpg", "image/jpeg"},
            {"jpeg", "image/jpeg"},
            {"webp", "image/webp"},
            {"ico", "image/x-icon"},
            {"pdf", "application/pdf"}
        ]}
    ],
    case inets:start(httpd, Config) of
        {ok, _Pid} -> {ok, nil};
        {error, Reason} -> {error, list_to_binary(io_lib:format("~p", [Reason]))}
    end.
