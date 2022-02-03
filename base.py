# these import statements are the libraries required in order to access the functions we need
from ryu.base import app_manager
from ryu.controller import ofp_event
from ryu.controller.handler import CONFIG_DISPATCHER, MAIN_DISPATCHER
from ryu.controller.handler import set_ev_cls
from ryu.ofproto import ofproto_v1_3

# create a class for our app manager called 'L2Switch'
# this means that ryu-manager will register this ryu-app
class L2Switch(app_manager.RyuApp):
  
  # define the OpenFlow version this ryu-app will use
  # here we are saying that we want OpenFlow v1.3 to be used
  OFP_VERSIONS = [ofproto_v1_3.OFP_VERSION]
  
  # initialization incantation of this class (pass in args to self)
  # these next two lines ask calling function arguments to be passed to the initialization of our application (L2Switch) 
  def __init__(self, *args, **kwargs):
    super(L2Switch, self).__init__(*args, **kwargs)
    
  # The ryu-manager will do the hardwork of recieving OpenFlow packets
  # If one of those packets is a switch features interrogation, the EventOFPSwitchFeatures will be created
  # ryu-manger will call this function because it has been registered for the event EventOFPSwitchFeatures
  # Handle switch feature interrogation event 
  @set_ev_cls(ofp_event.EventOFPSwitchFeatures, CONFIG_DISPATCHER)
  def switch_features_handler(self, ev):
    # The line below will have the ryu-app do nothing 
    return
  
  # Handle switch packet in event
  @set_ev_cls(ofp_event.EventOFPPacketIn, MAIN_DISPATCHER)
  def packet_in_handler(self, ev):
    # The line below will have the ryu-app do nothing 
    return
