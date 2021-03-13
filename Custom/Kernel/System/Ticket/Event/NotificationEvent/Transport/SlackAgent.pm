# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (GPL). If you
# did not receive this file, see https://www.gnu.org/licenses/gpl-3.0.tx
# --
package Kernel::System::Ticket::Event::NotificationEvent::Transport::SlackAgent;

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
    my $Token = $ConfigObject->Get('SlackAgent::BotToken');
	my $MemberIDField = $ConfigObject->Get('SlackAgent::MemberIDField');		
	my $HttpType = $ConfigObject->Get('HttpType');
	my $FQDN = $ConfigObject->Get('FQDN');
	my $ScriptAlias = $ConfigObject->Get('ScriptAlias');
	my $TicketHook = $ConfigObject->Get('Ticket::Hook');
	
    #get recipient data
    my %Recipient = %{ $Param{Recipient} };
	my $UserFullName = $Recipient{UserFullname};
    my $RecipientMemberID = $Recipient{$MemberIDField};
	
	return if $Recipient{Type} eq 'Customer';
    return unless $RecipientMemberID;
	
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
    my $TicketURL = $HttpType.'://'.$FQDN.'/'.$ScriptAlias.'index.pl?Action=AgentTicketPrint;TicketID='.$TicketID;
     
     	if ( !$Ticket{Service} )
	{
		$Ticket{Service} = "N/A";
	}
     
	# For Asynchronous sending
	my $TaskName = substr "Recipient".rand().$RecipientMemberID, 0, 255;
	
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
				Function => 'SendMessageSlackAgent',
				Params   => 
						{
							Token    => $Token,
							SlackMemberID  => $RecipientMemberID,	
							TicketURL	=>	$TicketURL,
							TicketNumber	=>	$TicketHook.$Ticket{TicketNumber},
							Message	=>	$Notification{Body},
							Created	=> $TicketDateTimeString,
							Queue	=> $Ticket{Queue},
							Service	=>	$Ticket{Service},
							Priority=>	$Ticket{Priority},	
							TicketID      => $TicketID, #sent for log purpose
							ReceiverName      => $UserFullName, #sent for log purpose
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
        TemplateFile => 'SlackAgent',
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

=back

=head1 TERMS AND CONDITIONS

This software is part of the OTRS project (L<http://otrs.org/>).

This software comes with ABSOLUTELY NO WARRANTY. For details, see
the enclosed file COPYING for license information (AGPL). If you
did not receive this file, see L<http://www.gnu.org/licenses/agpl.txt>.

=cut

