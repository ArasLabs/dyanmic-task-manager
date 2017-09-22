<!DOCTYPE html>
<!-- (c) Copyright by Aras Corporation, 2004-2013. -->
<!-- #INCLUDE FILE="include/utils.aspx" -->
<html>
<head>
	<title></title>
	<script type="text/javascript" src="../javascript/include.aspx?classes=XmlDocument"></script>
	<script type="text/javascript" src="../javascript/include.aspx?classes=ScriptSet2"></script>
	<script type="text/javascript" src="../javascript/XmlHttpRequestManager.js"></script>
	<script type="text/javascript" src="../javascript/Licensing.js"></script>
	<%
		Dim usertype As String
		usertype = Request.QueryString("UserType")
		Trace.Write("UserType", usertype)
	%>
	<script type="text/javascript">
		var toolbarApplet = null,
			menuApplet = null,
			aras = null;

		onload = function() {
			aras = top.aras;
			window.parent.window.loadToolBar(OnToolbarItemClick, function(control) {
				document.toolbar = toolbarApplet = control;
				initToolbar();
			});

			window.parent.window.loadMainMenu({
				xml: top.aras.getI18NXMLResource("main_menu.aspx?UserType=<%=usertype%>"), 
				onSelect: OnMenuItemClick, 
				onCheck: onCheckMenu},
				function (control) {
					menuApplet = document.menu = control;
					initMenuApplet();
					finalizeInit();
				}
			);

			// Calls from original onload Handler
			document.body.scroll = "no";
			top.aras.registerEventHandler("VariableChanged", window, window.onVariableChanged);
			top.aras.registerEventHandler("PreferenceValueChanged", window, window.onPreferenceValueChanged);

			var b = top.aras.getPreferenceItemProperty("Core_GlobalLayout", null, "core_no_tabs_in_tab_view");
			if (b == null)
			{
				var variable = top.aras.getItemFromServerByName('Variable','Relationship Tabs','value').node;
				if (variable)
				{
					var showTabs = (top.aras.getItemProperty(variable,'value') == 'yes');
					top.aras.setPreferenceItemProperties("Core_GlobalLayout", null, {core_no_tabs_in_tab_view: !showTabs});
				}
			}

			window.parent.refreshPageLayout();
		}

		function setControlEnabled(ctrlName, b) {
			if (b == undefined) b = true;

			try {
				var tbi = activeToolbar.getElement(ctrlName);
				if (tbi) tbi.setEnabled(b);
			}
			catch (excep) { }

			try {
				var mi = menuApplet.findItem(ctrlName);
				if (mi) mi.setEnabled(b);
			}
			catch (excep) { }
		}

		function setControlState(ctrlName, b) {
			if (b == undefined) b = true;

			try {
				var tbi = activeToolbar.getElement(ctrlName);
				if (tbi) tbi.setState(b);
			}
			catch (excep) { }

			try {
				var mi = menuApplet.findItem(ctrlName);
				if (mi) mi.setState(b);
			}
			catch (excep) { }
		}

		function setActiveToolbar(toolbarId) {
			if (!toolbarApplet) return null;
			toolbarApplet.ShowToolbar(toolbarId);
			activeToolbar = toolbarApplet.getActiveToolbar();

			if (activeToolbar) {
				setControlEnabled("no_tabs", true);
				setControlState("no_tabs", top.aras.getPreferenceItemProperty("Core_GlobalLayout", null, "core_no_tabs_in_tab_view") == 'true');
				setControlState("tear_off", true);
			}

			return activeToolbar;
		}

		function getActiveToolbarId() {
			if (!activeToolbar) return undefined;
			return activeToolbar.getId();
		}

		function showDefaultToolbar() {
			return setActiveToolbar("main_toolbar");
		}

		function setAllControlsEnabled(b) {
			if (b == undefined) b = true;

			var activeTbId = getActiveToolbarId();
			var tbElements = activeToolbar.GetButtons("$");
			tbElements = tbElements.replace("no_tabs", "");
			tbElements = tbElements.replace("help_context", "");
			tbElements = tbElements.replace("Logout", "");

			tbElements = tbElements.split("$");
			for (var i = 0; i < tbElements.length; i++) {
				if (tbElements[i]) {
					var tbi = activeToolbar.getElement(tbElements[i]);
					if (tbi)
						tbi.setEnabled(b);
				}
			}

			var mainMenuElements = new Array("new", "save", "open", "download", "checkin", "checkout", "checkout_2dir", "undo_checkout", "print", "export2Excel", "export2Word", "purge", "delete", "edit", "view", "saveAs", "lock", "unlock", "undo", "promote", "revisions", "copy2clipboard");
			for (var i = 0; i < mainMenuElements.length; i++) {
				var mi = menuApplet.findItem(mainMenuElements[i]);
				if (mi) mi.setEnabled(b);
			}
		}

		var menuFrameReady = false;
		var activeToolbar = null;

		function initMenuApplet() {
			var tmp = menuApplet.findItem('show_text');
			if (tmp) tmp.setState(top.aras.getPreferenceItemProperty("Core_GlobalLayout", null, "core_show_labels") == 'true');
			tmp = menuApplet.findItem('wildcards');
			if (tmp) tmp.setState(top.aras.getPreferenceItemProperty("Core_GlobalLayout", null, "core_use_wildcards") == 'true');
			tmp = menuApplet.findItem('append');
			if (tmp) tmp.setState(top.aras.getPreferenceItemProperty("Core_GlobalLayout", null, "core_append_items") == 'true');
			tmp = menuApplet.findItem('no_tabs');
			if (tmp) tmp.setState(top.aras.getPreferenceItemProperty("Core_GlobalLayout", null, "core_no_tabs_in_tab_view") == 'true');
			tmp = menuApplet.findItem('show_properties');
			if (tmp) tmp.setState(top.aras.getPreferenceItemProperty("Core_GlobalLayout", null, "core_show_item_properties") == 'true');
			tmp = menuApplet.findItem('soap_save');
			if (tmp) tmp.setState(top.aras.getVariable('SaveRequest') == 'true');
			//For IR-002047 "Sort Issues"      
			tmp = menuApplet.findItem('sort_pages');
			if (tmp) tmp.setState(top.aras.getVariable('SortPages') == 'true');
			tmp = menuApplet.findItem("debug_on_off");
			if (tmp) {
				var debugOnOff = (top.aras.getVariable("debug") == "true");
				tmp.setState(debugOnOff);
				top.aras.DEBUG = debugOnOff;
			}
		}

		function initToolbar() {
			toolbarApplet.showLabels(top.aras.getPreferenceItemProperty("Core_GlobalLayout", null, "core_show_labels") == 'true');
			toolbarApplet.loadXml(top.aras.getI18NXMLResource("main_toolbar.xml"));

			showDefaultToolbar();
		}

		function finalizeInit() {
			updateGenericActions();
			updateGenericReports();
			menuFrameReady = true;
		}

		function onVariableChanged(params) {
			if (!params || !menuApplet) return;

			var varName = params.varName;
			var varValue = params.varValue;

			if (varName == "SaveRequest") {
				varValue = (varValue == true);
				if (varValue != menuApplet.findItem('soap_save').getCheck())
					setControlState('soap_save', varValue);
			}
			else if (varName == "debug") {
				window.onerror = null;
				varValue = (varValue == true);
				top.aras.DEBUG = !top.aras.DEBUG;

				if (varValue != menuApplet.findItem('debug_on_off').getCheck())
					setControlState('debug_on_off', varValue);
			}
		}

		function onPreferenceValueChanged(params) {
			if (!params) return;
			var menuItemNm;
			var newValue;
			if ("Core_GlobalLayout" == params.type) {
				newValue = (top.aras.getPreferenceItemProperty(params.type, null, params.propertyName) == "true");
				if ("core_show_labels" == params.propertyName) {
					menuItemNm = "show_text";
					toolbarApplet.showLabels(newValue);
				}
				else if ("core_show_item_properties" == params.propertyName) {
					menuItemNm = "show_properties";
					if (top.main.work.isItemsGrid && top.main.work.showProperties) {
						top.main.work.showProperties(newValue);
						parent.updateTogglePanel(true);
					}
				}
			}

			if (menuItemNm) {
				var menuItem = menuApplet.findItem(menuItemNm);
				if (!menuItem) return;
				if (newValue != menuItem.getCheck()) setControlState(menuItemNm, newValue);

				var tbi = activeToolbar.getElement(menuItemNm);
				if (tbi) tbi.setState(newValue);
			}
		}

		function enablePopup(b) {
			document.menu.enablePopup(!b);
			top.main.tree.mainTreeApplet.enablePopup(b);
		}

		var genericActionCount = 0;

		function addActionEntry(name, actionId, active, pos) {
			var menu = menuApplet.findMenu('actions_menu');
			if (pos == undefined) menu.addItem(name, actionId, active);
			else menu.addItem(name, actionId, active, pos);
			menu.setEnableFlag(true);
		}

		function addActionSeparator() {
			var menu = menuApplet.findMenu('actions_menu');
			menu.addSeparatorItem();
		}

		function getActionEntriesCount() {
			return menuApplet.findMenu('actions_menu').getItemsCount();
		}

		/*
		 * this function deletes specified by "i" parameter menu entry from
		 * the menu specified by "menuName" parameter
		 * was designed to be used in deleteActionEntry and deleteReportEntry
		 * Actions and Reports are context dependent menus.
		 * 
		 * The function makes menu disabled if there are no more entries.
		 * 
		 * If you need to know if the function succeeded - check return value
		 */
		function deleteSpecialMenuEntry(menuName, i) {
			var actI = parseInt(i);
			if (isNaN(actI) || actI < 0) return false;

			var menu = menuApplet.findMenu(menuName);
			if (!menu) return false;

			menu.deleteItemAt(actI);
			if (menu.getItemsCount() == 0) {
				menu.setEnableFlag(false);
			}

			return true;
		}

		function deleteActionEntry(i) {
			return deleteSpecialMenuEntry("actions_menu", i);
		}

		function updateGenericActions() {
			var menu = menuApplet.findMenu('actions_menu');

			for (var i = genericActionCount - 1; i >= 0; i--) {
				menu.deleteItemAt(i);
			}

			var qry = new top.Item('Action', 'get');
			qry.setProperty('type', 'generic');
			qry.setAttribute('select', 'name,label');

			var actions = qry.apply();
			var c = actions.getItemCount();

			for (var i = 0; i < c; i++) {
				var action = actions.getItemByIndex(i);
				var lbl = action.getProperty('label');
				if (!lbl) lbl = action.getProperty('name');
				addActionEntry(
				  lbl,
				  'action:' + action.getID() + ':                                ',
				  true, i);
			}

			genericActionCount = c;

			menu.setEnableFlag(getActionEntriesCount() > 0);
		}

		function openHelpUrl(url) {
			window.open(url);
		}

		function onShowControlsApiReferenceCommand() {
			top.aras.uiShowControlsApiReferenceCommand();
		}

		function onAbout() {
			top.aras.AlertAbout(window);
		}

		function onMySession() {
			top.aras.AlertAboutSession();
		}

		var genericReportCount = 0;

		function addReportEntry(name, reportId, active, pos) {
			var menu = menuApplet.findMenu('reports_menu');
			if (pos == undefined) menu.addItem(name, reportId, active);
			else menu.addItem(name, reportId, active, pos);
			menu.setEnableFlag(true);
		}

		function addReportSeparator() {
			var menu = menuApplet.findMenu('reports_menu');
			menu.addSeparatorItem();
		}

		function getReportEntriesCount() {
			return menuApplet.findMenu('reports_menu').getItemsCount();
		}

		function deleteReportEntry(i) {
			return deleteSpecialMenuEntry("reports_menu", i);
		}

		function updateGenericReports() {
			var menu = menuApplet.findMenu('reports_menu');

			for (var i = genericReportCount - 1; i >= 0; i--) {
				menu.deleteItemAt(i);
			}

			var qry = new top.Item('Report', 'get');
			qry.setProperty('type', 'generic');
			qry.setAttribute('select', 'name,label');

			var reports = qry.apply();
			var c = reports.getItemCount();

			for (var i = 0; i < c; i++) {
				var report = reports.getItemByIndex(i);
				var lbl = report.getProperty('label');
				if (!lbl) lbl = report.getProperty('name');
				addReportEntry(lbl, 'report:' + report.getID() + ':                                ', true, i);
			}

			genericReportCount = c;
			menu.setEnableFlag(getReportEntriesCount() > 0);
		}

		function setWholeMenuEnabled(b) {
			try {
				enablePopup(b);
			}
			catch (excep) { }
		}

		function setToolbarEnabled(b, totalFlg)
		{
		  try
		  {
			if(b == undefined) b = true;
			if(!totalFlg)
			{
			  activeToolbar.getElement('new').setEnabled(b);
			  activeToolbar.getElement('save').setEnabled(b);
			  activeToolbar.getElement('delete').setEnabled(b);
			  activeToolbar.getElement('edit').setEnabled(b);
			  activeToolbar.getElement('view').setEnabled(b);
			  activeToolbar.getElement('saveAs').setEnabled(b);
			  activeToolbar.getElement('print').setEnabled(b);
			  activeToolbar.getElement('export2Excel').setEnabled(b);
			  activeToolbar.getElement('export2Word').setEnabled(b);
			  activeToolbar.getElement('promote').setEnabled(b);
			  activeToolbar.getElement('lock').setEnabled(b);
			  activeToolbar.getElement('unlock').setEnabled(b);
			  activeToolbar.getElement('undo').setEnabled(b);
			  activeToolbar.getElement('revisions').setEnabled(b);
			}
			else {}
		  }
		  catch(excep) {}
		}

		function onCheckMenu(menuItem)
		{
			var cmdID = menuItem.getId();
			var currChk = menuItem.getCheck();
			var currChk_str = currChk.toString();

			var param = undefined;

			if (cmdID == "debug_on_off")
				top.aras.setVariable("debug", currChk);
			if (cmdID == 'soap_save')
				top.aras.setVariable("SaveRequest", currChk);
			else
			//For IR-002047 "Sort Issues"
				if (cmdID == 'sort_pages')
					top.aras.setVariable("SortPages", currChk);
				else if (cmdID == 'show_text')
					top.aras.setPreferenceItemProperties("Core_GlobalLayout", null, { core_show_labels: currChk_str })
				else if (cmdID == 'wildcards')
					top.aras.setPreferenceItemProperties("Core_GlobalLayout", null, { core_use_wildcards: currChk_str });
				else if (cmdID == 'append')
					top.aras.setPreferenceItemProperties("Core_GlobalLayout", null, { core_append_items: currChk_str });
				else if (cmdID == "no_tabs")
				{
					var element;
					element = document.toolbar.getActiveToolbar().getElement('no_tabs');
					if (element) element.setState(currChk);

					if (top.main.work.onNoTabsCommand) top.main.work.onNoTabsCommand();
					else top.aras.setPreferenceItemProperties("Core_GlobalLayout", null, { core_no_tabs_in_tab_view: currChk_str });
				}
				else if (cmdID == "show_properties")
				{
					top.aras.setPreferenceItemProperties("Core_GlobalLayout", null, { core_show_item_properties: currChk_str });
				}
				else if (cmdID == "ShowMainTree")
				{
					top.aras.setVariable("ShowMainTree", currChk);
				}
			processCommand(cmdID);
		}

		function execInTearOffWin(itemID, cmdID, param) {
			if (cmdID == undefined || cmdID == '') return false;

			var win = top.aras.uiFindWindowEx(itemID);
			var res = null;
			if (win && win.name != 'work') {
				win.focus();
				if (win.frames["tearoff_menu"] && win.frames["tearoff_menu"].onClickMenuItem) {
					res = win.frames["tearoff_menu"].onClickMenuItem(cmdID, param);
					if (!res || !res['result']) res = true;
				}
				if (res == null) res = true;
			}

			if (win && top.aras.isWindowClosed(win)) top.aras.uiUnregWindowEx(itemID);

			return res;
		}


		function OnMenuItemClick(menuItem) {
			processCommand(menuItem.getId());
		}

		function OnToolbarItemClick(tbItem) {
			var tbItemID = tbItem.getId();
			var param = undefined;

			//it is important to call handler without any setTimeout (IR-006484)
			processCommand(tbItemID, param);
		}

		function processCommand(cmdID, param) {
			var workerFrame = top.main.work;
			var emptyID = '                                ';

			var cmdHandlerName = "on" + (cmdID.substr(0, 1).toUpperCase() + cmdID.substr(1)) + "Command";
			var cmdHandler = workerFrame[cmdHandlerName];
			if (!cmdHandler) cmdHandler = window[cmdHandlerName];

			if (cmdHandler) {
				if (!top.aras.DEBUG) {
					try {
						cmdHandler();
					}
					catch (excep) {
					}
				}
				else
					cmdHandler();

				return;
			}

			var id = cmdID;
			var itemID = '';
			var itemIDs = new Array();
			var itemNd, res, counter;
			var itemTypeName = '';

			if (workerFrame.isLifeCycleTool) {
				itemTypeName = 'Life Cycle Map';
				itemID = workerFrame.currLCID;
				itemIDs[0] = itemID;
			}
			else if (workerFrame.isWorkflowTool) {
				itemTypeName = 'Workflow Map';
				itemID = workerFrame.currWFID;
				itemIDs[0] = itemID;
			}
			else if (workerFrame.isFormTool) {
				itemTypeName = 'Form';
				itemID = workerFrame.currFormId;
				itemIDs[0] = itemID;
			}
			else if (workerFrame.isItemsGrid && workerFrame.gridApplet) {
				itemTypeName = workerFrame.itemTypeName;
				itemID = workerFrame.gridApplet.getSelectedId();
				itemIDs = workerFrame.gridApplet.getSelectedItemIds();
			}
			else if (workerFrame.viewMode == 'tab view') {
				itemTypeName = workerFrame.itemTypeName;
				itemID = workerFrame.itemID;
				itemIDs[0] = itemID;
			}
			else if (workerFrame.tree) {
				itemTypeName = workerFrame.itemTypeName;
				itemID = workerFrame.tree.theItemID;
				itemIDs[0] = workerFrame.tree.theItemID;
			}

			//processing of "common" commands started
			if (id == 'tear_off') {
				var el = activeToolbar.getElement('tear_off');
				if (el) top.aras.setVariable('TearOff', el.getState());
			} //tear_off command

			else if (cmdID == 'show_getcounter') {
				top.aras.Show_Get_Counter();
			}
			<%If usertype = "admin" Then %>
			else if (cmdID == 'reset_LFS') {
				var res = top.aras.resetLifeCycle(itemTypeName, itemID);
				if (!res) {
					top.aras.AlertError(top.aras.getResource("", "mainmenu.reset_lcs_failed"));
					return false;
				}
				else {
					var win = top.aras.uiFindWindowEx(itemID);
					if (win) win.document.location.reload();

					if (workerFrame.isItemsGrid) workerFrame.updateRow(top.aras.getItemById('', itemID, 0));
				}
			}

			else if (cmdID == 'setDefault_LC') {
				var res = top.aras.setDefaultLifeCycle(itemTypeName, itemID);
				if (!res) {
					top.aras.AlertError(top.aras.getResource("", "mainmenu.set_lc_failed"));
					return false;
				}
				else {
					var win = top.aras.uiFindWindowEx(itemID);
					if (win) {
						var itemNd = top.aras.getItemById(itemTypeName, itemID, 0);
						top.aras.uiReShowItemEx(itemID, itemNd);
					}

					if (workerFrame.isItemsGrid) workerFrame.updateRow(top.aras.getItemById(itemTypeName, itemID, 0));
				}
			}

			else if (id == 'reset_itemAccess') {
				if (itemID == '') {
					top.aras.AlertError(top.aras.getResource("", "mainmenu.item_must_select"));
					return false;
				}

				for (var i = 0; i < itemIDs.length; i++) {
					var res = top.aras.resetItemAccess(itemTypeName, itemIDs[i]);
					if (!res) {
						top.aras.AlertError(top.aras.getResource("", "mainmenu.reset_access_failed"));
						return false;
					}
					else {
						var wnd = top.aras.windowsByName[itemID];
						if (wnd && !top.aras.isWindowClosed(wnd)) wnd.document.location.reload();
						if (workerFrame.isItemsGrid)
							workerFrame.updateRow(top.aras.getItemById('', itemID, 0));
					}
				}
			}

			else if (cmdID == 'clear_form_cache') {
				var c = top.aras.getCacheObject();
				with (top.aras) for (var formID in c.Forms) removeFormFromClientCache(formID);
			}

			else if (cmdID == 'clear_metadata_cache') {
				top.aras.clearClientMetadataCache();
			}

			else if (id == 'load_cache') {
				with (top.aras) {
					if (!loadCache())
						top.aras.AlertError(top.aras.getResource("", "mainmenu.load_cache_failed"));
					else
						top.aras.AlertError(top.aras.getResource("", "mainmenu.cache_loaded"));
				}
			}
			else if (id == 'users_management') {
				var licensingObject = new Licensing(top.aras);
				licensingObject.ShowLicenseManagerDialog();
			}
			else if (id == 'activate_feature') {
				var licensingObject = new Licensing(top.aras);
				licensingObject.ActivateFeature();
			}
			else if (id == "view_feature_tree") {
				var licensingObject = new Licensing(top.aras);
				licensingObject.ViewFeatureTree();
			}
			else if (id == "update_feature_tree") {
				var licensingObject = new Licensing(top.aras);
				licensingObject.UpdateFeatureTreeUI();
			}
			else if (id == 'import_feature_license') {
				var licensingObject = new Licensing(top.aras);
				licensingObject.ImportFeatureLicense();
			}
			else if (cmdID == 'rebuild_keyedname') {
				var itemTypeNames = top.aras.prompt(top.aras.getResource("", "mainmenu.rebuild_keyed_name_prop"), itemTypeName);
				if (itemTypeNames == null)
					return true;

				var soapController = new top.SoapController(onRebuildKeyedNamesComplete);
				soapController.custom_statusId = top.aras.showStatusMessage("status", ' Rebuilding Keyed Names ...', '../images/Progress.gif');
				top.aras.soapSend('rebuildKeyedName', '<ItemTypes>' + itemTypeNames + '</ItemTypes>', undefined, undefined, soapController);

				function onRebuildKeyedNamesComplete(res) {
					top.aras.clearStatusMessage(this.custom_statusId);
					if (res.getFaultCode() != 0) {
						top.aras.AlertError(top.aras.getResource("", "mainmenu.rebuilding_kn_failed", res.getFaultString()));
						return false;
					}

					top.aras.AlertSuccess(top.aras.getResource("", "mainmenu.kn_rebuilt"));
				}
			}
			<%End If %>
			//new command
			else if (cmdID == 'new') {
				if (workerFrame.onNewCommand)
					workerFrame.onNewCommand();
				else {
					if (!itemTypeName)
						itemTypeName = top.main.tree.mainTreeApplet.getSelectedId();

					if (itemTypeName) {
						itemTypeName = itemTypeName.slice(itemTypeName.lastIndexOf('/') + 1);
						top.aras.uiNewItemEx(itemTypeName);
					}
				}

				return true;
			}
			else if (id == 'edit') {
				if (workerFrame.onEditCommand)
					return workerFrame.onEditCommand();
				else {
					if (execInTearOffWin(itemID, 'edit'))
						return true;

					var itemNd = top.aras.getItemById('', itemID, 0);
					if (!itemNd) return false;
					var isTemp = top.aras.isTempID(itemID);
					var locked_by = top.aras.getItemProperty(itemNd, 'locked_by_id');

					if (!isTemp && locked_by == '') {
						if (!top.aras.lockItem(itemID))
							return false;
						else if (workerFrame.isItemsGrid) with (workerFrame) {
							gridApplet.cells(itemID, 0).setValue('<img src="../images/LockedByMe.svg"/>');
							onSelectItem(itemID);
						}
					} //if(!isTemp && !myLock)

					setTimeout("viewSelectedItem('" + itemID + "');", 1);
					if (workerFrame.isFormTool) {
						setControlEnabled("edit", true);
						setControlEnabled("view", true);
						setControlEnabled("lock", false);
						setControlEnabled("unlock", true);
						setControlEnabled("delete", false);
					}
				}
			} //edit command

			else if (id == 'view') {
				if (workerFrame.onViewCommand)
					return workerFrame.onViewCommand();
				else {
					var itemNd = top.aras.getItemById('', itemID, 0);
					if (!itemNd)
						return false;

					var isTemp = top.aras.isTempID(itemID);
					var myLock = (top.aras.getItemProperty(itemNd, 'locked_by_id') == top.aras.getUserID());

					if (!isTemp && myLock) {
						if (!top.aras.unlockItem(itemID))
							return false;
						else if (workerFrame.isItemsGrid) with (workerFrame) {
							gridApplet.cells(itemID, 0).setValue('<img src="../images/UnlockItem.svg" style="max-width: 20px; max-height: 20px; width: auto; height: auto;">');
							onSelectItem(itemID);
						}
					} //if(!isTemp && !myLock)

					setTimeout("viewSelectedItem('" + itemID + "');", 1);
					if (workerFrame.isFormTool) {
						setControlEnabled("edit", true);
						setControlEnabled("view", true);
						setControlEnabled("lock", true);
						setControlEnabled("delete", true);
						setControlEnabled("unlock", false);
					}
				}
			} //view command

			else if (cmdID == 'undo') {
				if (workerFrame.onUndoCommand)
					return workerFrame.onUndoCommand();
				else {
					res = top.aras.unlockItem(itemID);
					if (!res) {
						res = top.aras.getItemById(res.getAttribute('type'), itemID, 0);
						if (!res) {
							top.aras.AlertError(top.aras.getResource("", "mainmenu.item_doesnt_exist"));
							return false;
						}
					}

					if (workerFrame.isFormTool || workerFrame.isLifeCycleTool || workerFrame.isWorkflowTool)
						workerFrame.setViewMode();
					else
						workerFrame.location.reload();

					setControlEnabled('lock', true);
					setControlEnabled('unlock', false);
					setControlEnabled('undo', false);
				}
			}

			else if (id == 'version_item') {
				if (!itemID)
					return;

				var item = top.aras.getItemById(itemTypeName, itemID, 0);
				if (!item)
					return;

				var itemTypeName = item.getAttribute('type');
				var res = top.aras.versionItem(itemTypeName, itemID);
				if (res && workerFrame.isItemsGrid) {
					var id = res.getAttribute("id");
					if (workerFrame.grid.getRowIndex(id) == -1) {
						workerFrame.deleteRow(item);
						workerFrame.updateRow(res);
						workerFrame.onSelectItem(id);
					}
				}
			}

			//get_files command
			else if (cmdID == 'get_files' && workerFrame.onGetFilesCommand) {
				workerFrame.onGetFilesCommand();
			}

			//checkin command
			else if (cmdID == 'checkin' && workerFrame.onCheckInCommand) {
				workerFrame.onCheckInCommand();
			}

			//checkout command
			else if (cmdID == 'checkout' && workerFrame.onCheckOutCommand) {
				workerFrame.onCheckOutCommand();
			}

			//checkout_2dir command
			else if (cmdID == 'checkout_2dir' && workerFrame.onCheckOut2DirCommand) {
				workerFrame.onCheckOut2DirCommand();
			}

			//undo_checkout command
			else if (cmdID == 'undo_checkout' && workerFrame.onUndoCheckOutCommand) {
				workerFrame.onUndoCheckOutCommand();
			}

			//help_contents command
			else if (cmdID == 'help_contents') {
				top.aras.AlertError(top.aras.getResource("", "mainmenu.not_implemented"));
			}

			else if (id == 'export2Excel') {
				var gridXml = workerFrame.grid.getXML(true);
				top.aras.export2Office(gridXml, id, undefined, itemTypeName);
			}
			else if (id == 'export2Word') {
				var gridXml = workerFrame.grid.getXML(false);
				top.aras.export2Office(gridXml, id);
			}

			else if (id == 'no_tabs') {
				if (workerFrame.onNoTabsCommand)
					workerFrame.onNoTabsCommand();
				else {
					var el = activeToolbar.getElement('no_tabs');
					if (el) {
						var val = el.getState();
						top.aras.setPreferenceItemProperties("Core_GlobalLayout", null, { core_no_tabs_in_tab_view: val.toString() });
						document.menu.findItem('no_tabs').setState(val);
					}
				}
			}

			else if (cmdID == 'change_working_dir') {
				var userID = top.aras.getUserID();
				var userNd = top.aras.getLoggedUserItem();
				if (!userNd) {
					top.aras.AlertError(top.aras.getResource("", "common.unknown_user"));
					return false;
				}

				var newDir = top.aras.vault.selectFolder();
				if (!newDir)
					return true;

				top.aras.setItemProperty(userNd, 'working_directory', newDir);
				top.aras.setUserWorkingDirectory(userID, newDir);
			}

			else if (cmdID == 'change_passwd') {
				var userNd = top.aras.getLoggedUserItem();
				if (!userNd)
					return false;

				userNd = userNd.cloneNode(true);
				userNd.setAttribute('action', 'get');
				userNd.setAttribute('select', 'id');
				top.aras.applyItem(userNd.xml);

				var data = new Object();
				data['title'] = top.aras.getResource("", "common.change_pwd");
				data['md5'] = top.aras.getPassword();
				data['oldMsg'] = top.aras.getResource("", "common.old_pwd");
				data['newMsg1'] = top.aras.getResource("", "common.new_pwd");
				data['newMsg2'] = top.aras.getResource("", "common.confirm_pwd");
				data['errMsg1'] = top.aras.getResource("", "common.old_pwd_wrong");
				data['errMsg2'] = top.aras.getResource("", "common.check_pwd_confirmation");
				data['errMsg3'] = top.aras.getResource("", "common.pwd_empty");
				data['check_empty'] = true;
				var methNm = "User_pwd_checkPolicy";
				var methNd = top.aras.getItem("Method", "name='" + methNm + "'", "<name>" + methNm + "</name>", 0);
				var methCode = (methNd) ? top.aras.getItemProperty(methNd, "method_code") : "";
				data['code_to_check_pwd_policy'] = methCode;
				data.aras = top.aras;
				var options = {
					dialogWidth: 300,
					dialogHeight: 180,
					center: true
				},
				newPwd = top.aras.modalDialogHelper.show('DefaultModal', window, data, options, 'changeMD5Dialog.html');

				if (!newPwd) {
					return true;
				}
				else {
					var r2 = top.aras.soapSend("ChangeUserPassword", "<new_password>" + newPwd + "</new_password>");
					if (r2.getFaultCode() != 0) {
						top.aras.AlertError(r2);
					}
					else {
						top.aras.setPassword(newPwd, false);
						r2 = top.aras.soapSend('ValidateUser', '');
						if (!r2) {
							return top.aras.getResource("", "aras_object.validate_user_failed_communicate_with_innovator_server");
						}
					}
				}
			}

			else if (cmdID == 'change_esignature') {
				var userNd = top.aras.getLoggedUserItem();
				if (!userNd)
					return false;

				var data = new Object();
				data['title'] = top.aras.getResource("", "mainmenu.change_sign");
				data['md5'] = top.aras.getItemProperty(userNd, 'esignature');
				data['oldMsg'] = top.aras.getResource("", "mainmenu.old_sign");
				data['newMsg1'] = top.aras.getResource("", "mainmenu.new_sign");
				data['newMsg2'] = top.aras.getResource("", "mainmenu.confirm_sign");
				data['errMsg1'] = top.aras.getResource("", "mainmenu.old_sign_wrong");
				data['errMsg2'] = top.aras.getResource("", "mainmenu.check_sign_confirmation");
				data.aras = top.aras;
				var options = {
					dialogWidth: 300,
					dialogHeight: 180,
					center: true
				},
				newESignature = top.aras.modalDialogHelper.show('DefaultModal', window, data, options, 'changeMD5Dialog.html');

				if (newESignature == undefined)
					return true;
				else {
					top.aras.setItemProperty(userNd, 'esignature', newESignature);
					userNd.setAttribute('action', 'edit');
					top.aras.applyItem(userNd.xml);
				}
			}

			else if (cmdID == 'help_context') {
				top.aras.ShowContextHelp(itemTypeName);
			}
			else if (cmdId == 'show_projects_load_summary') {
				showLoadSummaryView();
			}
			else if (cmdID == 'current_session')
				onMySession();
			else if (cmdID == 'help_about')
				onAbout();
			else if (cmdID == 'addItem2Package')
				top.aras.addItemToPackageDef(itemIDs, itemTypeName);
			else if (cmdID.search(/^action:/) == 0) {
				var actID = cmdID.split(':');
				var itID = actID[2];
				actID = actID[1];

				var action = top.aras.getItemFromServer('Action', actID, 'name,method(name,method_type,method_code),type,target,location,body,on_complete(name,method_type,method_code),item_query');
				if (action) {
					var actType = action.getProperty('type');

					if (itemIDs.length == 0 || 'generic' == actType || actType == 'itemtype') {
						if (itID == emptyID)
							top.aras.invokeAction(action.node, undefined, '');
						else
							top.aras.invokeAction(action.node, itID, '');
					}
					else {
						for (var counter = 0; counter < itemIDs.length; counter++) {
							var itemID = itemIDs[counter];
							top.aras.invokeAction(action.node, itID, itemID);
						}
					}
				}
			}
			else if (cmdID.search(/^report:/) == 0) {
				var repID = cmdID.split(':');
				var itID = repID[2];
				repID = repID[1];

				var report = top.aras.getItemFromServer('Report', repID, 'name,target,location,report_query');
				if (report) {
					if (itemIDs.length == 0) {
						if (itID == emptyID) {
							top.aras.runReport(report.node);
						}
						else {
							top.aras.runReport(report.node, itID);
						}
					}
					else {
						for (var counter = 0; counter < itemIDs.length; counter++) {
							itemID = itemIDs[counter];

							var tmpItm = top.aras.createXMLDocument();
							tmpItm.loadXML("<Item type='" + itemTypeName + "' id='" + itemID + "' />");
							tmpItm = tmpItm.documentElement;

							if (itID == emptyID) {
								top.aras.runReport(report.node, undefined, tmpItm);
							}
							else {
								top.aras.runReport(report.node, itID, tmpItm);
							}
						}
					}
				}
			}
			else if (cmdID == 'delete_user_preferences') {
				var params = { aras: top.aras };
				top.aras.modalDialogHelper.show("DefaultModal", top, params, { dialogHeight: 400, dialogWidth: 330, resizable: 'yes' }, "SitePreference/deletePreferencesDialog.html");
			}
		}
		var onClickMenuItem = processCommand;

		function viewSelectedItem(itemID, itemType, viewMode) {
			if (!itemID) return false;
			if (itemType === undefined) itemType = "";
			if (viewMode === undefined) {
				viewMode = top.aras.getPreferenceItemProperty("Core_GlobalLayout", null, "core_view_mode");
			}

			var win = top.aras.windowsByName[itemID];
			if (win && !top.aras.isWindowClosed(win) && win.name != 'work') {
				win.focus();
				return true;
			}

			var itemNd = top.aras.getItemById(itemType, itemID, 0);
			if (!itemNd) return false;

			var itemTypeName = itemNd.getAttribute('type');
			var re = new RegExp("Desktop.html$", "i")

			if (itemTypeName == 'Form' && !re.test(top.main.work.location.pathname)) {
				top.main.work.location.replace('FormTool/formtool.html?formID=' + itemID);
			}
			else {
				top.aras.uiShowItemEx(itemNd, viewMode);
			}

			return true;
		}

		var __mainTreeShowStr = "";
		var __hiddenMainTreeStr = "0,*";

		function isMainTreeShown() {
			return top.main.window.isMainTreeShown();
		}

		function onPrintCommand() {
			var itm = top.main.work.document.item;
			if (itm) top.aras.uiShowItemEx(itm, 'print view');
		}

		function onExport2OfficeCommand(targetAppType) {
			var itm = top.main.work.document.item;
			if (itm) top.aras.export2Office("", targetAppType, itm);
		}

		function onShowMainTreeCommand() {
			var hideMainTree = isMainTreeShown();
			setControlState("ShowMainTree", !hideMainTree);
			top.main.window.hideOrShowTree(hideMainTree);
		}

		function onLogoutCommand() {
			<% if (Client_config("top_close_on_logout") <> "false") then %>
				top.open('', '_self'); 
				top.aras.browserHelper.closeWindow(window);
			<% else %>
				var res = top.aras.dirtyItemsHandler();
				if (res == undefined || res.logout_confirmed) {
					top.aras.logout();
					alert(top.aras.getResource("","mainmenu.logout_done"));
				}
			<% End if %>
		}

		onunload = function unload_handler() {
			aras.unregisterEventHandler("VariableChanged", window, window.onVariableChanged);
			aras.unregisterEventHandler("PreferenceValueChanged", window, window.onPreferenceValueChanged);
		}
	</script>
	<script LANGUAGE='JavaScript' SRC='modal.js'></script>
	<script LANGUAGE='JavaScript' SRC='MainMenuAdd.js'></script>
</head>
</html>
