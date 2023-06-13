function Get-TemplatePages {
    param(
        [parameter(mandatory)]
        $ParentPath
    )
    #GraphQL request
    $query = @"
{
    pages {
        list(orderBy: TITLE) {
            id
            path
            title
        }
    }
}
"@
    $body = @{
        query = $query
    } | ConvertTo-Json

    #Get all the pages from Template structure
    $templates = (Invoke-RestMethod -Method POST -Uri $wikiUrl -Headers $header -Body $body -ContentType "application/json").data.pages.list.Where({$_.path -like "$templateParentPath*"})
    $pages = @()
    $templates | ForEach-Object {
        $_.id
        $body = @"
{"query":"{pages {single (id: $($_.id)){path,title,content,editor}}}"}
"@
        $pages += Invoke-RestMethod -Method POST -Uri $wikiUrl -Body $body -Headers $header -ContentType "application/json"
    }

    return $pages
}
function New-Page {
    param(
        [parameter(mandatory)]
        $Content,
        [parameter(mandatory)]
        $Title,
        [parameter(mandatory)]
        $Path
    )

    #Convert the page so it works with GraphQL
    $Content = $Content | ConvertTo-Json
    
    #Create query
    $query = @"
    mutation {
        pages {
            create(content: $Content,description: "",editor: "markdown",isPublished: true,isPrivate: false,locale: "en",path: "$Path",tags: [],title: "$Title")
            {
                page {
                    id
                    title
                }
            }
        }
    }
"@
    $body = @{
        query = $query
    } | ConvertTo-Json

    #Create page
    Invoke-WebRequest -Uri $wikiUrl -Method POST -Body $body -Headers $header -ContentType "application/json;charset=utf-8"
}

#Connection
$token = "Bearer <API KEY>"
$header = @{Authorization = "$token"}
$wikiUrl = "<WIKIJSAddress>/graphql"

#Customer information
$customerName = "Test customer"
$customerID = "CUS101010"

#Template information
$templateParentPath = "Customers/CUSTOMER-TEMPLATE"
$templateName = $templateParentPath.split("/") | Select-Object -Last 1

#Get all template pages
$pages = Get-TemplatePages -ParentPath $templateParentPath

#Loop through all template pages and create them in the correct structure
$pages.data | ForEach-Object {
    $page = $_.pages.single

    #Set the name of the Customer for the parent file
    if ($page.Path -eq "$templateParentPath"){
        $page.Title = $customerName
    }

    #Set the new page path with the customer name
    $page.Path = $page.Path -replace("$templateName","$customerID")

    New-Page -Content $page.Content -Title $page.Title -Path $page.Path
}