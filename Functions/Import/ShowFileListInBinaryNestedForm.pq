//Show binary form of list of files w/ PathNames in nested form.  i.e.
      /*
      Name	Content
      \\nasv0618\CHC_CLM_Legacy\LCHC_Agr\20250410\Agr_CV\files_metadata.csv	Binary.FromText(...)
      \\nasv0618\CHC_CLM_Legacy\LCHC_Agr\20250410\Agr_Incr_CDLink\files_metadata.csv	Binary.FromText(...)
      \\nasv0618\CHC_CLM_Legacy\TES_Agr\20250410\Opps_Incremental_CDLink\files_metadata.csv	Binary.FromText(...)
      \\nasv0618\CHC_CLM_Legacy\TES_Agr\20250410\Opps_CV\files_metadata.csv	Binary.FromText(...)
      \\nasv0618\CHC_CLM_Legacy\TES_Agr\20250410\ContrDocs_CV\files_metadata.csv	Binary.FromText(...)
      \\nasv0618\CHC_CLM_Legacy\TES_Agr\20250410\Acct-Opps-ContrDoc_Att\files_metadata.csv	Binary.FromText(...)
      */


let
    Paths = {        "\\nasv0618\CHC_CLM_Legacy\LCHC_Agr\20250410\Agr_CV\files_metadata.csv",
        "\\nasv0618\CHC_CLM_Legacy\LCHC_Agr\20250410\Agr_Incr_CDLink\files_metadata.csv",
"\\nasv0618\CHC_CLM_Legacy\TES_Agr\20250410\Opps_Incremental_CDLink\files_metadata.csv",
"\\nasv0618\CHC_CLM_Legacy\TES_Agr\20250410\Opps_CV\files_metadata.csv",
"\\nasv0618\CHC_CLM_Legacy\TES_Agr\20250410\ContrDocs_CV\files_metadata.csv",
"\\nasv0618\CHC_CLM_Legacy\TES_Agr\20250410\Acct-Opps-ContrDoc_Att\files_metadata.csv"
    },
    GetFileContent = (path) => [Name = path, Content = File.Contents(path)],
    Records = List.Transform(Paths, each GetFileContent(_)),
    Table = Table.FromRecords(Records)
in
    Table
