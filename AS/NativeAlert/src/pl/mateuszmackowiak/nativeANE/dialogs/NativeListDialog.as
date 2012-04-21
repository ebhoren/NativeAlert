/** 
 * @author Mateusz Maćkowiak
 * @see http://mateuszmackowiak.wordpress.com/
 * @since 2011
 */
package pl.mateuszmackowiak.nativeANE.dialogs
{
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.StatusEvent;
	import flash.external.ExtensionContext;
	import flash.system.Capabilities;
	
	import pl.mateuszmackowiak.nativeANE.NativeDialogEvent;
	import pl.mateuszmackowiak.nativeANE.NativeDialogListEvent;

	
	
	/** 
	 * @author Mateusz Maćkowiak
	 * @see http://mateuszmackowiak.wordpress.com/
	 * @since 2011
	 */
	public class NativeListDialog extends EventDispatcher
	{
		//---------------------------------------------------------------------
		//
		// Public Static Constants
		//
		//---------------------------------------------------------------------
		/**
		 * the id of the extension that has to be added in the descriptor file
		 */
		public static const EXTENSION_ID : String = "pl.mateuszmackowiak.nativeANE.NativeAlert";
		
		public static const STYLE_HORIZONTAL:int = 0x00000001;
		public static const STYLE_SPINNER:int = 0x00000000;
		
		
		/**
		 * use the device's default alert theme with a dark background
		 * <br>Constant Value: 4 (0x00000004)
		 */
		public static const ANDROID_DEVICE_DEFAULT_DARK_THEME:uint = 0x00000004;
		/**
		 *  use the device's default alert theme with a dark background.
		 * <br>Constant Value: 5 (0x00000005)
		 */
		public static const ANDROID_DEVICE_DEFAULT_LIGHT_THEME:uint = 0x00000005;
		/**
		 * use the holographic alert theme with a dark background
		 * <br>Constant Value: 2 (0x00000002)
		 */
		public static const ANDROID_HOLO_DARK_THEME:uint = 0x00000002;
		/**
		 * use the holographic alert theme with a light background
		 * <br>Constant Value: 3 (0x00000003)
		 */
		public static const ANDROID_HOLO_LIGHT_THEME:uint = 0x00000003;
		/**
		 * use the traditional (pre-Holo) alert dialog theme
		 * <br>the default style for Android devices
		 * <br>Constant Value: 1 (0x00000001)
		 */
		public static const DEFAULT_THEME:uint = 0x00000001;
		
		//---------------------------------------------------------------------
		//
		// Private Static Constants
		//
		//---------------------------------------------------------------------
		private static var _defaultTheme:int = DEFAULT_THEME;
		private static var isAndroid:Boolean=false;
		private static var isIOS:Boolean=false;
		
		//---------------------------------------------------------------------
		//
		// Private Properties.
		//
		//---------------------------------------------------------------------
		private var context:ExtensionContext;
		private var _title:String="";
		private var _buttons:Vector.<String>=null;
		private var _theme:int = -1;
		private var _cancelable:Boolean = false;
		private var _message:String="";
		private var _list:Vector.<Object> = null;
		private var _selectedIndex:int = -1;
		private var _isShowing:Boolean=false;
		//---------------------------------------------------------------------
		//
		// Public Methods.
		//
		//---------------------------------------------------------------------
		
		/**
		 * Events:
		 *
		 * <br> flash.events.ErrorEvent
		 * <br> pl.mateuszmackowiak.nativeANE.NativeDialogEvent
		 * @author Mateusz Maćkowiak
		 * @see http://www.mateuszmackowiak.art.pl/blog
		 * @since 2012
		 * @see pl.mateuszmackowiak.nativeANE.NativeDialogEvent
		 * @see pl.mateuszmackowiak.nativeANE.NativeDialogListEvent
		 * @see flash.events.ErrorEvent
		 */
		public function NativeListDialog(theme:uint=NaN)
		{
			if(Capabilities.os.toLowerCase().indexOf("linux")>-1)
				isAndroid = true;
			else if(Capabilities.os.toLowerCase().indexOf("iph")>-1)
				isIOS = true;
			else{
				trace("NativeListDialog is not supported on this platform");
				return;
			}
			
			if(!isNaN(theme))
				_theme = theme;
			else
				_theme = _defaultTheme;
			
			try{
				context = ExtensionContext.createExtensionContext(EXTENSION_ID, "ListDialogContext");
				context.addEventListener(StatusEvent.STATUS, onStatus);
			}catch(e:Error){
				showError("Error initiating contex of the extension "+e.message,e.errorID);
			}
		}
		
		
		
		/**
		 * shows the NativeListDialog dialog
		 * @param labels list of posible chocies. Can not be null
		 * @param checkedLabel selected index. if -1 non is selected. <br><b>AVAILABLE ONLY ON ANDROID</b>
		 * @param buttons list of labels of buttons in dialog <b><i>On Android</i></b> max 3.Can be set by propertie buttons.
		 * @param cancleble if pressing outside the popup or the back button hides the popup. If null is set to default or as set by setCancelable
		 * @see pl.mateuszmackowiak.nativeANE.dialogs.NativeTextInputDialog#setCancelable()
		 * 
		 */
		public function showSingleChoice(labels:Vector.<String>,checkedLabel:int=-1,buttons:Vector.<String>=null,cancleble:Object=null):Boolean
		{
			if(_theme ==-1)
				_theme = defaultTheme;
			if(buttons!=null)
				_buttons = buttons;
			if(cancleble!==null)
				_cancelable = cancleble;

			if(isNaN(checkedLabel))
				checkedLabel = -1;
			if(labels!==null && labels.length>0){
				_list = new Vector.<Object>();
				for each (var label:String in labels) 
				{
					_list.push({label:label,selected:false});
				}
				if(checkedLabel!==-1)
					_list[checkedLabel].selected = true;
			}else
				return false;
			_selectedIndex = checkedLabel;
			try{
				if(isAndroid)
					context.call("showListDialog","create",_title,_buttons,labels,checkedLabel,_cancelable,_theme);
				else
					context.call("show",_title,_message,_buttons,labels,checkedLabel);
				return true;
			}catch(e:Error){
				showError("Error calling show method "+e.message,e.errorID);
			}
			return false;
		}

		
		/**
		 * shows the NativeListDialog dialog
		 * @param labels list of posible chocies. Can not be null
		 * @param checkedLabels list of boolean values selected index. if -1 non is selected. (must be null or exact the same length as labels)
		 * @param buttons list of labels of buttons in dialog <b><i>On Android</i></b> max 3. Can be set by propertie buttons.
		 * @param cancleble if pressing outside the popup or the back button hides the popup. If null is set to default or as set by setCancelable
		 * @see pl.mateuszmackowiak.nativeANE.dialogs.NativeTextInputDialog#setCancelable()
		 * 
		 */
		public function showMultiChoice(labels:Vector.<String>,checkedLabels:Vector.<Boolean>,buttons:Vector.<String>=null,cancelable:Object=null):Boolean
		{
			if(_theme ==-1)
				_theme = defaultTheme;
			if(buttons!=null)
				_buttons = buttons;
			if(cancelable!==null)
				_cancelable = cancelable;
			
			if(labels!==null && labels.length>0){
				_list = new Vector.<Object>();
				for each (var label:String in labels) 
				{
					_list.push({label:label,selected:false});
				}
				const l:int = checkedLabels.length;
				if(checkedLabels!=null && labels.length == l){
					for (var i:int = 0; i < l; i++) 
					{
						_list[i].selected = checkedLabels[i];
					}
				}
			}else
				return false;
			_selectedIndex = -1;
			try{
				if(isAndroid)
					context.call("showListDialog","create",_title,_buttons,labels,checkedLabels,_cancelable,_theme);
				else
					context.call("show",_title,_message,_buttons,labels,checkedLabels);
				return true;
			}catch(e:Error){
				showError("Error calling show method "+e.message,e.errorID);
			}
			return false;
		}
		
		

		/**
		 * list of posible chocies.
		 */
		public function get labels():Vector.<String>{
			var lab:Vector.<String> = new Vector.<String>();
			if(_list!==null){
				for each (var obj:Object in _list) 
				{
					lab.push(obj.label);
				}
			}
			return lab;
		}
		
		
		/**
		 * list of selected labels 
		 */
		public function get selectedLabels():Vector.<String>{
			var lab:Vector.<String> = new Vector.<String>();
			if(_list!==null && _list.length>0){
				for each (var obj:Object in _list) 
				{
					if(obj.selected == true)
						lab.push(obj.label);
				}
				if(lab.length>0 && _selectedIndex>-1)
					lab.push(_list[_selectedIndex].label);
			}
			return lab;
		}
		
		/**
		 * list of selected indexes
		 */
		public function get selectedIndexes():Vector.<int>{
			var indexes:Vector.<int> = new Vector.<int>();
			if(_list!==null && _list.length>0){
				for (var i:int = 0; i < _list.length; i++) 
				{
					if(_list[i].selected == true)
						indexes.push(i);
				}
				if(indexes.length>0 && _selectedIndex>-1)
					indexes.push(_selectedIndex);
			}
			return indexes;
		}
		
		
		/**
		 * selected index. If multichoice -1
		 */
		public function get selectedIndex():int{
			return _selectedIndex;
		}
		
		
		/**
		 * selected label. If multichoice null
		 */
		public function get selectedLabel():String{
			if(_selectedIndex>-1 && _list!=null && _list.length>0)
				return _list[_selectedIndex].label;
			else
				return null;
		}
		
		
		
		
		/**
		 * if the dialog is showing
		 */
		public function isShowing():Boolean{
			if(context){
				if(isAndroid){
					const b:Boolean = context.call("showListDialog","isShowing");
					_isShowing = b;
					return b;
				}/*else if(isIOS){
					const b2:Boolean = context.call("isShowing");
					_isShowing = b2;
					return b2;
				}*/
			}
			return false;
			
		}
		

		
		/**
		 * The title of the dialog
		 * @return if call sucessfull
		 */
		public function setTitle(value:String):Boolean
		{
			if(value!==_title){
				_title = value;
				if(_isShowing){
					try{
						if(isAndroid){
							context.call("showListDialog","setTitle",value);
							return true;
						}
						/*if(isIOS){
							context.call("setTitle",value);
							return true;
						}*/
						return false;
					}catch(e:Error){
						showError("Error setting title "+e.message,e.errorID);
					}
				}
			}
			return false;
		}
		/**
		 * The title of the dialog
		 */
		public function getTitle():String
		{
			return _title;
		}

		
		/**
		 * The message of the dialog
		 * <br><b>AVAILABLE ONLY ON IOS</b>
		 * @return if call sucessfull
		 */
		public function setMessage(value:String):Boolean
		{
			if(value!==_message){
				_message = value;
				try{
					if(_isShowing && isIOS){
							context.call("updateMessage",value);
						return true;
					}
				}catch(e:Error){
					showError("Error setting message "+e.message,e.errorID);
				}
			}
			return false;
		}
		/**
		 * The message of the dialog
		 * @see setMessage()
		 */
		public function get message():String
		{
			return _message;
		}
		
		/**
		 * if back button on Android cancles Dialog
		 * <br><b>AVAILABLE ONLY ON ANDROID</b>
		 * @return if call sucessfull
		 */
		public function setCancelable(value:Boolean):Boolean
		{
			if(_cancelable!==value){
				_cancelable = value;
				if(_isShowing){
					try{
						if(isAndroid){
							context.call("showListDialog","setCancelable",value);
							return true;
						}
						/*if(isIOS){
						context.call("setCancleble",value);
						return true;
						}*/
					}catch(e:Error){
						showError("Error setting secondary progress "+e.message,e.errorID);
					}
				}
			}
			return false;	
		}
		/**
		 * if back button cancles Dialog
		 * <br><b>AVAILABLE ONLY ON ANDROID</b>
		 */
		public function getCancelable():Boolean
		{
			return _cancelable;
		}
		
		
		
		/**
		 * buttons list of labels of buttons in dialog
		 * (if isShowing will be ignored until next show)
		 */
		public function set buttons(value:Vector.<String>):void
		{
			_buttons = value;
		}
		/**
		 * @private
		 */
		public function get buttons():Vector.<String>
		{
			return _buttons;
		}


		
		
		
		/**
		 * the theme of the NativeTextInputDialog
		 * (if isShowing will be ignored until next show)
		 */
		public function set theme(value:int):void
		{
			if(!isNaN(value))
				_theme = value;
			else
				_theme = _defaultTheme;
		}
		/**
		 * @private
		 */
		public function get theme():int
		{
			return _theme;
		}
		

		
		/**
		 * hides the dialog if is showing and does not dispach any event
		 * <br><b>AVAILABLE ONLY ON ANDROID</b>
		 * @return if call sucessfull
		 * @see pl.mateuszmackowiak.nativeANE.dialogs.NativeTextInputDialog#hide()
		 */
		public function dismiss():Boolean
		{
			_isShowing = false;
			try{
				if(context!=null){
					if(isAndroid){
						context.call("showListDialog","dismiss");
						return true;
					}
					/*if(isIOS){
					context.call("dismiss");
					return true;
					}*/
				}
				return false;
			}catch(e:Error){
				showError("Error calling hide method "+e.message,e.errorID);
			}
			return false;
		}
		/**
		 * hides the dialog if is showing and dispaches NativeDialogEvent.CANCELED
		 * @return if call sucessfull
		 * @see pl.mateuszmackowiak.nativeANE.dialogs.NativeTextInputDialog#dismiss()
		 */
		public function hide():Boolean
		{
			_isShowing = false;
			try{
				if(context!=null){
					if(isAndroid){
						context.call("showListDialog","hide");
						return true;
					}
					/*if(isIOS){
						context.call("hide");
						return true;
					}*/
				}
				return false;
			}catch(e:Error){
				showError("Error calling hide method "+e.message,e.errorID);
			}
			return false;
		}
		
		/**
		 * Disposes of this ExtensionContext instance.<br><br>
		 * The runtime notifies the native implementation, which can release any associated native resources. After calling <code>dispose()</code>,
		 * the code cannot call the <code>call()</code> method and cannot get or set the <code>actionScriptData</code> property.
		 * @return if call sucessfull
		 */
		public function dispose():Boolean
		{
			_isShowing = false;
			try{
				context.dispose();
				context.removeEventListener(StatusEvent.STATUS, onStatus);
				return true;
			}catch(e:Error){
				showError("Error calling dispose method "+e.message,e.errorID);
			}
			return false;
		}
		
		
		//---------------------------------------------------------------------
		//
		// Public Static Methods.
		//
		//---------------------------------------------------------------------
		/**
		 * Whether the extension class is available on the device (true);<br>otherwise false
		 */
		public static function get isSupported():Boolean{
			if(Capabilities.os.toLowerCase().indexOf("linux")>-1 || Capabilities.os.toLowerCase().indexOf("iph")>-1)
				return true;
			else 
				return false;
		}
		
		/**
		 * the theme from which to get the dialog's style 
		 */
		public static function set defaultTheme(value:int):void
		{
			_defaultTheme = value;
		}
		/**
		 * @private
		 */
		public static function get defaultTheme():int
		{
			return _defaultTheme;
		}
		//---------------------------------------------------------------------
		//
		// Private Methods.
		//
		//---------------------------------------------------------------------
		/**
		 * @private
		 */
		private function showError(message:String,id:int=0):void
		{
			if(hasEventListener(ErrorEvent.ERROR))
				dispatchEvent(new ErrorEvent(ErrorEvent.ERROR,false,false,message,id));
			else
				throw new Error(message,id);
		}
		/**
		 * @private
		 */
		private function onStatus(event:StatusEvent):void
		{
			try{
				if(event.code == NativeDialogEvent.CLOSED){
					if(dispatchEvent(new NativeDialogEvent(NativeDialogEvent.CLOSED,event.level))){
						trace("dismiss");
						if(isAndroid){
							dismiss();
						}
						_isShowing = false;
					}
					
				}else if(event.code == NativeDialogEvent.CANCELED){
					const e2:Event = new NativeDialogEvent(NativeDialogEvent.CANCELED,event.level);
					if(dispatchEvent(e2)){
						trace("dismiss");
						if(isAndroid){
							dismiss();
						}
						_isShowing = false;
					}
					
				}else if(event.code == NativeDialogEvent.OPENED){
					if(dispatchEvent(new NativeDialogEvent(NativeDialogEvent.OPENED,""))){
						if(isAndroid){
							context.call("showListDialog","show");
						}
						_isShowing = true;
					}
				}else if(event.code == NativeDialogListEvent.LIST_CHANGE){
					var index:int = -1;
					if(event.level.indexOf("_")>-1){
						const args:Array = event.level.split("_");
						if(isAndroid)
							index = int(args[0]);
						else
							index = _list.length-1-int(args[0]);
						var selected:Boolean=false;
						const selectedStr:String= String(args[1]).toLocaleLowerCase();
						if(selectedStr=="true" || selectedStr=="1")
							selected = true;
						_list[index].selected = selected;
						
						dispatchEvent(new NativeDialogListEvent(NativeDialogListEvent.LIST_CHANGE,index,selected));
					}else{
						if(isAndroid)
							index = int(event.level);
						else 
							index = _list.length-1-int(event.level);
						_selectedIndex = index;
						dispatchEvent(new NativeDialogListEvent(NativeDialogListEvent.LIST_CHANGE,index,true));
					}
					
				}else if(event.code ==ErrorEvent.ERROR){
					dispatchEvent(new ErrorEvent(ErrorEvent.ERROR,false,false,event.level,0));
				}else{
					showError(event.toString());
				}
			}catch(e:Error){
				showError(e.message,e.errorID);
			}
		}
	}
}