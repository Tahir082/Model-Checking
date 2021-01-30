mtype= {event_part_req, pass_usr_dt, payment_req, payment, pass_payment_info, payment_confirm, ack};
chan user= [2] of {mtype, bit};
chan server= [2]of {mtype, bit};
chan database= [2] of {mtype, bit};

proctype User(chan userCh, serverCh, databaseCh)
	{
		bit snd, rcv;
		do
		:: serverCh! event_part_req(snd) -> userCh?ack(rcv);
		:: userCh? payment_req(rcv) -> server! payment(snd);
		od
	}
proctype Server(chan userCh, serverCh, databaseCh)
	{
		bit snd, rcv;
		do
		:: serverCh? event_part_req(rcv) -> databaseCh! pass_usr_dt(snd);
		:: serverCh? ack(rcv) -> userCh! ack(rcv);
		:: serverCh? ack(rcv) -> userCh! payment_req(snd);
		:: serverCh? payment(rcv)-> databaseCh! pass_payment_info(snd);
		:: serverCh? ack(rcv) -> userCh! ack(rcv);
		od
	}
proctype Database(chan userCh, serverCh, databaseCh)
	{	
		bit rcv;
		do
		:: databaseCh? pass_usr_dt(rcv) -> serverCh! ack(rcv);
		:: databaseCh? pass_payment_info(rcv) -> serverCh! ack(rcv);
		od
	}
	init
	{
	run User(user, server, database);
	run Server(user, server, database);
	run Database(user, server, database);
	}	
