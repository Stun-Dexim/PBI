/**
Promote the first table row as column names, but keep the current header
if the value in the first row is empty.  
Useful for Transforming headers in during union operation where incoming table has some common fields but many fields are not common. 

For simpler use cases check built-in function `Table.PromoteHeaders`
**/

let
    Source = (table as table) as table =>
let
    ExtraHeaders = Table.First(table),
    OldHeaders = Table.ColumnNames(table),
    NewHeaders = List.Transform(
        OldHeaders,
        (CurrentHeader) =>
        let
            Current = CurrentHeader,
            Candidate = Record.Field(ExtraHeaders, CurrentHeader)
        in
            if
                Candidate <> "" and
                Candidate <> null and
                Candidate <> 0
            then
                Text.From(Candidate)
            else
                Current
    ),
    RenamedColumns = Table.RenameColumns(
        Table.Skip(table, 1),
        List.Zip({OldHeaders, NewHeaders})
    ),
    Return = RenamedColumns
in
    Return
in
    Source
