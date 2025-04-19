//unions a list of files together, even if they are not same fields, order, etc.  All Fields will be represented.

let
    Paths = {
        "\\nasv0618\CHC_CLM_Legacy\LCHC_Agr\20250410\Agr_CV\files_metadata.csv",
        "\\nasv0618\CHC_CLM_Legacy\LCHC_Agr\20250410\Agr_Incr_CDLink\files_metadata.csv",
        "\\nasv0618\CHC_CLM_Legacy\TES_Agr\20250410\Opps_Incremental_CDLink\files_metadata.csv",
        "\\nasv0618\CHC_CLM_Legacy\TES_Agr\20250410\Opps_CV\files_metadata.csv",
        "\\nasv0618\CHC_CLM_Legacy\TES_Agr\20250410\ContrDocs_CV\files_metadata.csv",
        "\\nasv0618\CHC_CLM_Legacy\TES_Agr\20250410\Acct-Opps-ContrDoc_Att\files_metadata.csv"
    },
    GetFileContent = (path) => 
        let
            Content = Csv.Document(File.Contents(path), [Delimiter=",", Encoding=1252]),
            PromotedHeaders = Table.PromoteHeaders(Content, [PromoteAllScalars=true]),
            AddedPathColumn = Table.AddColumn(PromotedHeaders, "SourceFilePath", each path)
        in
            AddedPathColumn,
    Tables = List.Transform(Paths, each GetFileContent(_)),
    CombinedTable = Table.Combine(Tables)
in
    CombinedTable
