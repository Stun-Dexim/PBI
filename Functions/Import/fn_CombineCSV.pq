/**

function (TableWithNameAndContent as table, optional as nullable text, optional I or O Based Index as nullable number) as table
    
    Example: Combine CSV files using default comma delimiter (assumes all files are same format).
        Usage:
            let
                Output:
                    Source = Folder.Files(C:\YourFolderPath')
                    Filtered = Table . SelectRows (Source, each [Extension] = ". csv"),
                    Files — . SelectCoiumns (Filtered, {"Name", )
                Result = fnComb±neCSV (Files)
           in 
              Result
        Output: 
            Returns combined CSV files using ',' delimiter, with an added 'SrcFiie Index' column indicating the ordinai position of each original file.

**/



let        
    func = (TableWithNameAndContent as table, optional Delimiter as text, optional #"1 or 0 Based Index" as number) as table =>        
    let            
        Delim = if Delimiter = null then "," else Delimiter,  
        IndexBasis = if #"1 or 0 Based Index" = null then 1 else #"1 or 0 Based Index",              
  
        // Add a 1-based index to the input files  
        IndexedInput = Table.AddIndexColumn(TableWithNameAndContent, "SrcFile_Index", IndexBasis, 1),  
  
        FirstFileContent = IndexedInput{0}[Content],  
        FirstCsv = Csv.Document(FirstFileContent,[Encoding=1252, Delimiter=Delim]),  
        Headers = Table.PromoteHeaders(FirstCsv, [PromoteAllScalars=true]),  
        ColumnNames = Table.ColumnNames(Headers),  
  
        AddCsvTables = Table.AddColumn(IndexedInput, "CSVData", (x) =>                 
            let                    
                CsvContent = Csv.Document(x[Content],[Encoding=1252,Delimiter=Delim]),  
                Promoted = Table.PromoteHeaders(CsvContent,[PromoteAllScalars=true]),  
                Result = if x[Content] = FirstFileContent  
                            then Promoted  
                            else Table.Skip(Promoted,1)  
            in                    
                Result),  
  
        RemoveBinary = Table.RemoveColumns(AddCsvTables,{"Content"}),  
        ExpandAll = Table.ExpandTableColumn(RemoveBinary,"CSVData",ColumnNames),  
  
        // Insert "SrcFile_Index" at position 1  
        ResultTable = Table.ReorderColumns(ExpandAll, {"SrcFile_Index", "Name"} & ColumnNames)  
    in            
        ResultTable,          
  
    documentation = [  
        Documentation.Name = "fn_CombineCSV",  
        Documentation.Description = "Combines multiple CSV files into a single unified table, dynamically handling headers from the first file only, and adds a file index column.",  
        Documentation.LongDescription = "This function combines multiple CSV files provided in a table with exactly two columns named 'Name' (file name) and 'Content' (binary content of CSV files). It automatically promotes the headers from the first file and skips redundant headers from subsequent files. The resulting table includes an added 'SrcFile_Index' column indicating the ordinal position of each CSV file, and the original file name as the second column.",  
        Documentation.Category = "Table",  
        Documentation.Source = "Custom M Function",  
        Documentation.Author = "Your Name Here",  
        Documentation.Examples = {  
            [   
                Description = "Combine CSV files using default comma delimiter (assumes all files are same format).",    
                Code = "  
    let  
        Source = Folder.Files(""C:\YourFolderPath""),  
        Filtered = Table.SelectRows(Source, each [Extension] = "".csv""),  
        Files = Table.SelectColumns(Filtered, {""Name"", ""Content""}),  
        Result = fn_CombineCSV(Files)  
    in  
        Result",    
                Result = "Returns combined CSV files using ',' delimiter, with an added 'SrcFile_Index' column indicating the ordinal position of each original file."  
            ]                       
        }  
    ]    
in        
    Value.ReplaceType(func, Value.ReplaceMetadata(Value.Type(func), documentation))
