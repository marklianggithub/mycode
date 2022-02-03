"""Custom topology example

   Two directly connected switches plus a host for each switch:

      host --- switch --- switch --- host

   Adding the 'topos' dict with a key/value pair to generate our newly defined
   topology enables one to pass in '--topo=mytopo' from the command line.
   """

from mininet.topo import Topo

class NewTopo( Topo ):
       "Simple topology example."

       def __init__( self ):
           "Create custom topo."

           # Initialize topology
           Topo.__init__( self )

           # Add hosts and switches
           Left1Host = self.addHost( 'h1' )
           Left2Host = self.addHost( 'h2' )
           Cent1Host = self.addHost( 'h3' )
           Cent2Host = self.addHost( 'h4' )
           Right1Host = self.addHost( 'h5' )
           Right2Host = self.addHost( 'h6' )
           LeftSwitch = self.addSwitch( 's1' )
           CentSwitch = self.addSwitch( 's2' )
           RightSwitch = self.addSwitch( 's3' )

           # Add links
           self.addLink( Left1Host, LeftSwitch )
           self.addLink( Left2Host, LeftSwitch )
           self.addLink( Cent1Host, CentSwitch )
           self.addLink( Cent2Host, CentSwitch )
           self.addLink( Right1Host, RightSwitch )
           self.addLink( Right2Host, RightSwitch )
           self.addLink( LeftSwitch, CentSwitch )
           self.addLink( CentSwitch, RightSwitch )


topos = { 'newtopo': ( lambda: NewTopo() ) }
