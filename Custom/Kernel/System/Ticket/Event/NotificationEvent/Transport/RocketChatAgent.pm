# --
# Copyright (C) 2001-2017 OTRS AG, http://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# -- 
package Kernel::System::Ticket::Event::NotificationEvent::Transport::RocketChatAgent;

use strict;
use warnings;
no warnings 'redefine';

use Kernel::System::VariableCheck qw(:all);

use base qw(
    Kernel::System::Ticket::Event::NotificationEvent::Transport::Base
);

#use Data::Dumper;
#use Fcntl qw(:flock SEEK_END);
#use JSON::MaybeXS;

our @ObjectDependencies = (
    'Kernel::Config',
    'Kernel::Output::HTML::Layout',
    'Kernel::System::Email',
    'Kernel::System::Log',
    'Kernel::System::Main',
    'Kernel::System::Queue',
    'Kernel::System::SystemAddress',
    'Kernel::System::Ticket',
    'Kernel::System::User',
    'Kernel::System::Web::Request',
);

=head1 NAME

Kernel::System::Ticket::Event::NotificationEvent::Transport::Email - email transport layer

=head1 SYNOPSIS

Notification event transport layer.

=head1 PUBLIC INTERFACE

=over 4

=cut

=item new()

create a notification transport object. Do not use it directly, instead use:

    use Kernel::System::ObjectManager;
    local $Kernel::OM = Kernel::System::ObjectManager->new('');
    my $TransportObject = $Kernel::OM->Get('Kernel::System::Ticket::Event::NotificationEvent::Transport::Email');

=cut

sub new {
    my ( $Type, %Param ) = @_;

    my $Self = {};
    bless( $Self, $Type );

    return $Self;
}

sub SendNotification {
    my ( $Self, %Param ) = @_;

    for my $Needed (qw(TicketID UserID Notification Recipient)) {
        if ( !$Param{$Needed} ) {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message  => 'Need $Needed!',
            );
            return;
        }
    }
    
	# cleanup event data
    $Self->{EventData} = undef;
	
	my $ConfigObject = $Kernel::OM->Get('Kernel::Config');
    my $WebhookURL = $ConfigObject->Get('RocketChatAgent::WebhookURL');	
	my $UsernameField = $ConfigObject->Get('RocketChatAgent::UsernameField');		
	my $HttpType = $ConfigObject->Get('HttpType');
	my $FQDN = $ConfigObject->Get('FQDN');
	my $ScriptAlias = $ConfigObject->Get('ScriptAlias');
	
    #get recipient data
    my %Recipient = %{ $Param{Recipient} };
	my $UserFullName = $Recipient{UserFullname};
    my $RecipientUsername = $Recipient{$UsernameField};
	
	return if $Recipient{Type} eq 'Customer';
    return unless $RecipientUsername;
	
	my %Notification = %{ $Param{Notification} };
    $Notification{Body} = $Kernel::OM->Get('Kernel::System::HTMLUtils')->ToAscii( String => $Notification{Body} );
    $Notification{Subject} = $Kernel::OM->Get('Kernel::System::HTMLUtils')->ToAscii( String => $Notification{Subject} );
   
    my $TicketID = $Param{TicketID};
	my $TicketObject = $Kernel::OM->Get('Kernel::System::Ticket');
	
	# get ticket content
	my %Ticket = $TicketObject->TicketGet(
        TicketID => $TicketID ,
		UserID        => 1,
		DynamicFields => 0,
		Extended => 0,
    );
	
	return if !%Ticket;
	
    my $TicketDateTimeObject = $Kernel::OM->Create('Kernel::System::DateTime', ObjectParams => { String   => $Ticket{Created},});
	my $TicketDateTimeString = $TicketDateTimeObject->Format( Format => '%Y-%m-%d %H:%M' );
    my $TicketURL = $HttpType.'://'.$FQDN.'/'.$ScriptAlias.'index.pl?Action=AgentTicketZoom;TicketID='.$TicketID;
     
	# For Asynchronous sending
	my $TaskName = substr "Recipient".rand().$RecipientUsername, 0, 255;
	
	my $DateTimeObject = $Kernel::OM->Create(
        'Kernel::System::DateTime'
    );

	my $Add = $DateTimeObject->Add(
        Seconds       => 1,
    );
	
	my $DateTimeString = $DateTimeObject->ToString();
	
	# instead of direct sending, we use task scheduler
	my $TaskID = $Kernel::OM->Get('Kernel::System::Scheduler')->TaskAdd(
	        ExecutionTime            => $DateTimeString,
			Type                     => 'AsynchronousExecutor',
			Name                     => $TaskName,
			Attempts                 =>  1,
			MaximumParallelInstances =>  0,
			Data                     => 
			{
				Object   => 'Kernel::System::CustomMessage',
				Function => 'SendMessageRCAgent',
				Params   => 
						{
							Channel	=>	$RecipientUsername,
							WebhookURL	=>	$WebhookURL,
							TicketURL	=>	$TicketURL,
							TicketNumber	=>	$Ticket{TicketNumber},
							Message	=> $Notification{Body},
							Created	=> $TicketDateTimeString,
							Queue	=> $Ticket{Queue},
							State	=>	$Ticket{State},
							Service => $Ticket{Service},
							Priority => $Ticket{Priority},
							TicketID      => $TicketID, #sent for log purpose
							ReceiverName	=> $UserFullName, #sent for log purpose
						},
			},
		);
    
    #$Kernel::OM->Get('Kernel::System::Log')->Log(
    #    Priority => 'error',
    #    Message  => Dumper($All),
    #);
    
    return 1;
}

sub GetTransportRecipients {
    my ( $Self, %Param ) = @_;

    return ();
}

sub TransportSettingsDisplayGet {
    my ( $Self, %Param ) = @_;

    # get layout object
    my $LayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::Layout');

    # generate HTML
    my $Output = $LayoutObject->Output(
        TemplateFile => 'RocketChatAgent',
        Data         => \%Param,
    );

    return $Output;
}

sub TransportParamSettingsGet {
    my ( $Self, %Param ) = @_;

    for my $Needed (qw(GetParam)) {
        if ( !$Param{$Needed} ) {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message  => "Need $Needed",
            );
        }
    }

    return 1;
}

sub IsUsable {
    my ( $Self, %Param ) = @_;

    # define if this transport is usable on
    # this specific moment
    return 1;
}

1;

