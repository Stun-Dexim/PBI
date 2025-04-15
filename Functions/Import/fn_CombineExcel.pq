let  
    Source = let  
        func = (TableWithNameAndContent as table, optional SheetName as text, optional #"1 or 0 Based Index" as number) as table =>  
        let  
            Sheet = if SheetName = null then null else SheetName,  
            IndexBasis = if #"1 or 0 Based Index" = null then 1 else #"1 or 0 Based Index",  
  
            // Add a 1-based index to the input files  
            IndexedInput = Table.AddIndexColumn(TableWithNameAndContent, "SrcFile_Index", IndexBasis, 1),  
  
            // Get first file's content and headers  
            FirstFileContent = IndexedInput{0}[Content],  
            FirstExcel = Excel.Workbook(FirstFileContent),  
            FirstSheetData = if Sheet <> null   
                             then Table.SelectRows(FirstExcel, each [Kind]="Sheet" and [Name]=Sheet){0}[Data]  
                             else Table.SelectRows(FirstExcel, each [Kind]="Sheet"){0}[Data],  
            Headers = Table.PromoteHeaders(FirstSheetData, [PromoteAllScalars=true]),  
            ColumnNames = Table.ColumnNames(Headers),  
  
            // Process each Excel file, skipping headers after first file  
            AddExcelTables = Table.AddColumn(IndexedInput, "ExcelData", (x) =>  
                let  
                    ExcelContent = Excel.Workbook(x[Content]),  
                    SelectedSheetData = if Sheet <> null   
                                        then Table.SelectRows(ExcelContent, each [Kind]="Sheet" and [Name]=Sheet){0}[Data]  
                                        else Table.SelectRows(ExcelContent, each [Kind]="Sheet"){0}[Data],  
                    Promoted = Table.PromoteHeaders(SelectedSheetData,[PromoteAllScalars=true]),  
                    Result = if x[Content] = FirstFileContent  
                             then Promoted  
                             else Table.Skip(Promoted, 1) // Skip headers for subsequent files  
                in  
                    Result),  
  
            // Remove binary file content column  
            RemoveBinary = Table.RemoveColumns(AddExcelTables,{"Content"}),  
  
            // Expand the Excel data tables into the main table  
            ExpandAll = Table.ExpandTableColumn(RemoveBinary,"ExcelData",ColumnNames),  
  
            // Reorder columns to put index and filename first  
            ResultTable = Table.ReorderColumns(ExpandAll, {"SrcFile_Index", "Name"} & ColumnNames)  
        in  
            ResultTable,  
  
        documentation = [  
            Documentation.Name = "fn_CombineExcel",  
            Documentation.Description = "Combines multiple Excel files (.xls/.xlsx) into a single unified table, dynamically handling headers from the first file only, and adds a file index column.",  
            Documentation.LongDescription = "This function combines multiple Excel files provided in a table with exactly two columns named 'Name' (file name) and 'Content' (binary content of Excel files). It automatically promotes the headers from the first file and skips redundant headers from subsequent files. The resulting table includes an added 'SrcFile_Index' column indicating the ordinal position of each Excel file, and the original file name as the second column. You can optionally specify a sheet name; otherwise, the first sheet found in each file is used.",  
            Documentation.Category = "Table",  
            Documentation.Source = "Custom M Function",  
            Documentation.Author = "Your Name Here",  
            Documentation.Examples = {  
                [   
                    Description = "Combine Excel files specifying sheet name (assumes all files have same format).",  
                    Code = "  
let  
    Source = Folder.Files(""C:\YourFolderPath""),  
    Filtered = Table.SelectRows(Source, each [Extension] = "".xlsx"" or [Extension] = "".xls""),  
    Files = Table.SelectColumns(Filtered, {""Name"", ""Content""}),  
    Result = fn_CombineExcel(Files, ""Sheet1"")  
in  
    Result",  
                    Result = "Returns combined Excel files from 'Sheet1', with an added 'SrcFile_Index' column indicating the ordinal position of each original file."  
                ],  
                [  
                    Description = "Combine Excel files without specifying a sheet (defaults to first sheet in each file).",  
                    Code = "  
let  
    Source = Folder.Files(""C:\YourFolderPath""),  
    Filtered = Table.SelectRows(Source, each [Extension] = "".xlsx"" or [Extension] = "".xls""),  
    Files = Table.SelectColumns(Filtered, {""Name"", ""Content""}),  
    Result = fn_CombineExcel(Files)  
in  
    Result",  
                    Result = "Returns combined Excel files from the first worksheet of each file, with an added 'SrcFile_Index' column indicating the ordinal position of each original file."  
                ]  
            }  
        ]  
    in  
        Value.ReplaceType(func, Value.ReplaceMetadata(Value.Type(func), documentation))  
in  
    Source
