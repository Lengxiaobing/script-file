'******************************************************************************
'* File:     Exported_Excel_page.vbs
'* Purpose:  分目录递归，查找当前PDM下所有表，并导出Excel
'* Title:    
'* Category: 
'* Version:  1.0
'* Author:  787681084@qq.com
'******************************************************************************

Option Explicit
ValidationMode = True
InteractiveMode = im_Batch

'-----------------------------------------------------------------------------
' 主函数
'-----------------------------------------------------------------------------
' 获取当前活动模型
Dim mdl ' 当前的模型
Set mdl = ActiveModel
Dim EXCEL,catalog,sheet,catalogNum,rowsNum,linkNum
rowsNum = 1
catalogNum = 1
linkNum = 1

If (mdl Is Nothing) Then
    MsgBox "There is no Active Model"
Else
    SetCatalog
    ListObjects(mdl)
End If

'----------------------------------------------------------------------------------------------
' 子过程，用于扫描当前包并从当前包中打印对象的信息，然后对当前包的所有子包再次调用相同的子过程
'----------------------------------------------------------------------------------------------
Private Sub ListObjects(fldr)
    output "Scanning " & fldr.code
    Dim obj ' 运行对象
    For Each obj In fldr.children
        ' 调用子过程来打印对象上的信息
        DescribeObject obj
    Next
    ' 进入子包
    Dim f ' 运行文件夹
    For Each f In fldr.Packages
        '调用子程序扫描子程序包
        ListObjects f
    Next
End Sub

'-----------------------------------------------------------------------------
' 子过程，用于在输出中打印当前对象的信息
'-----------------------------------------------------------------------------
Private Sub DescribeObject(CurrentObject)
    if not CurrentObject.Iskindof(cls_NamedObject) then exit sub
    if CurrentObject.Iskindof(cls_Table) then 
		AddSheet CurrentObject.code
        ExportTable CurrentObject, sheet
		ExportCatalog CurrentObject
    else
        output "Found "+CurrentObject.ClassName+" """+CurrentObject.Name+""", Created by "+CurrentObject.Creator+" On "+Cstr(CurrentObject.CreationDate)   
    End if
End Sub

'----------------------------------------------------------------------------------------------
' 设置Excel的sheet页
'----------------------------------------------------------------------------------------------
Sub SetExcel()
    Set EXCEL= CreateObject("Excel.Application")

    ' 使Excel通过应用程序对象可见。
    EXCEL.Visible = True
    EXCEL.workbooks.add(-4167)'添加工作表
    EXCEL.workbooks(1).sheets(1).name ="pdm"
    set sheet = EXCEL.workbooks(1).sheets("pdm")

    ' 将一些文本放在工作表的第一行
    sheet.Cells(rowsNum, 1).Value = "表名"
    sheet.Cells(rowsNum, 2).Value = "表中文名"
    sheet.Cells(rowsNum, 3).Value = "表备注"
    sheet.Cells(rowsNum, 4).Value = "字段ID"
    sheet.Cells(rowsNum, 5).Value = "字段名"
    sheet.Cells(rowsNum, 6).Value = "字段中文名"
    sheet.Cells(rowsNum, 7).Value = "字段类型"
    sheet.Cells(rowsNum, 8).Value = "字段备注"
    sheet.cells(rowsNum, 9).Value = "主键"
    sheet.cells(rowsNum, 10).Value = "非空"
    sheet.cells(rowsNum, 11).Value = "默认值"
End Sub

'----------------------------------------------------------------------------------------------
' 导出目录结构
'----------------------------------------------------------------------------------------------
Sub ExportCatalog(tab)
	catalogNum = catalogNum + 1
	catalog.cells(catalogNum, 1).Value = tab.parent.name
	catalog.cells(catalogNum, 2).Value = tab.code
	catalog.cells(catalogNum, 3).Value = tab.comment
	'设置超链接
	catalog.Hyperlinks.Add catalog.cells(catalogNum,2), "",tab.code&"!A2"
End Sub 

'----------------------------------------------------------------------------------------------
' 导出sheet页
'----------------------------------------------------------------------------------------------
Sub ExportTable(tab, sheet)
	Dim col ' 运行列
	Dim colsNum
	colsNum = 0
    for each col in tab.columns
        colsNum = colsNum + 1
        rowsNum = rowsNum + 1
        sheet.Cells(rowsNum, 1).Value = tab.code
        'sheet.Cells(rowsNum, 2).Value = tab.name
        sheet.Cells(rowsNum, 2).Value = tab.comment
        'sheet.Cells(rowsNum, 4).Value = colsNum
        sheet.Cells(rowsNum, 3).Value = col.code
        'sheet.Cells(rowsNum, 4).Value = col.name
        sheet.Cells(rowsNum, 4).Value = col.datatype
        sheet.Cells(rowsNum, 5).Value = col.comment
		
		If col.Primary = true Then
			sheet.cells(rowsNum, 6) = "Y" 
        Else
			sheet.cells(rowsNum, 6) = "" 
        End If
        If col.Mandatory = true Then
			sheet.cells(rowsNum, 7) = "Y" 
        Else
			sheet.cells(rowsNum, 7) = "" 
		End If
		
		sheet.cells(rowsNum, 8).Value = col.defaultvalue
		'设置居中显示
		sheet.cells(rowsNum,6).HorizontalAlignment = 3
		sheet.cells(rowsNum,7).HorizontalAlignment = 3
    next
    output "Exported table: "+ +tab.Code+"("+tab.Name+")"
End Sub 

'----------------------------------------------------------------------------------------------
' 设置Excel目录页
'----------------------------------------------------------------------------------------------
Sub SetCatalog()
	Set EXCEL= CreateObject("Excel.Application")
	
	' 使Excel通过应用程序对象可见。
    EXCEL.Visible = True
    EXCEL.workbooks.add(-4167)'添加工作表
    EXCEL.workbooks(1).sheets(1).name ="表结构"
	EXCEL.workbooks(1).sheets.add
    EXCEL.workbooks(1).sheets(1).name ="目录"
    set catalog = EXCEL.workbooks(1).sheets("目录")

	catalog.cells(catalogNum, 1) = "模块"
	catalog.cells(catalogNum, 2) = "表名"
	catalog.cells(catalogNum, 3) = "表注释"
	
	' 设置列宽和自动换行
	catalog.Columns(1).ColumnWidth = 20
	catalog.Columns(2).ColumnWidth = 25
	catalog.Columns(3).ColumnWidth = 55
	
	'设置首行居中显示
	
	catalog.Range(catalog.cells(1,1),catalog.cells(1,3)).HorizontalAlignment = 3
	'设置首行字体加粗
	catalog.Range(catalog.cells(1,1),catalog.cells(1,3)).Font.Bold = True
End Sub 

'----------------------------------------------------------------------------------------------
' 新增sheet页
'----------------------------------------------------------------------------------------------
Sub AddSheet(sheetName)
	EXCEL.workbooks(1).Sheets(2).Select
	EXCEL.workbooks(1).sheets.add
	EXCEL.workbooks(1).sheets(2).name = sheetName
	set sheet = EXCEL.workbooks(1).sheets(sheetName)
	rowsNum = 1
	'将一些文本放在工作表的第一行
    sheet.Cells(rowsNum, 1).Value = "表名"
    'sheet.Cells(rowsNum, 2).Value = "表中文名"
    sheet.Cells(rowsNum, 2).Value = "表备注"
    'sheet.Cells(rowsNum, 4).Value = "字段ID"
    sheet.Cells(rowsNum, 3).Value = "字段名"
    'sheet.Cells(rowsNum, 4).Value = "字段中文名"
    sheet.Cells(rowsNum, 4).Value = "字段类型"
    sheet.Cells(rowsNum, 5).Value = "字段备注"
    sheet.cells(rowsNum, 6).Value = "主键"
    sheet.cells(rowsNum, 7).Value = "非空"
    sheet.cells(rowsNum, 8).Value = "默认值"
	
	'设置列宽
	sheet.Columns(1).ColumnWidth = 20
	sheet.Columns(2).ColumnWidth = 20
	sheet.Columns(3).ColumnWidth = 20
	sheet.Columns(4).ColumnWidth = 20
	sheet.Columns(5).ColumnWidth = 20
	sheet.Columns(6).ColumnWidth = 5
	sheet.Columns(7).ColumnWidth = 5
	sheet.Columns(8).ColumnWidth = 10

	'设置首行居中显示
	sheet.Range(sheet.cells(1,1),sheet.cells(1,8)).HorizontalAlignment = 3
	'设置首行字体加粗
	sheet.Range(sheet.cells(1,1),sheet.cells(1,8)).Font.Bold = True
	
	linkNum = linkNum + 1
	'设置超链接
	sheet.Hyperlinks.Add sheet.cells(1,1), "","目录"&"!B"&linkNum
End Sub 