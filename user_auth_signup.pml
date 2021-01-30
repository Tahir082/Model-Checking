mtype={auth_req, auth_send, send_signup_req, send_usr_dt, val_chk, ack};
chan user= [2] of {mtype, bit};
chan server= [2] of {mtype, bit};
chan database= [2] of {mtype, bit};

proctype User(chan userCh, serverCh, databaseCh)
{
	bit snd, rcv;
	do
	:: serverCh! auth_req(snd) -> userCh?ack(rcv);
	:: serverCh! send_signup_req(snd)-> userCh?ack(rcv);
	od
}

proctype Server(chan userCh, serverCh, databaseCh)
{
	bit snd, rcv;
	do
	:: serverCh? auth_req(rcv) -> databaseCh! auth_send(snd);
	:: serverCh? ack(rcv) -> userCh! ack(rcv);
	:: serverCh? send_signup_req(rcv) -> databaseCh! send_usr_dt(snd);
	:: serverCh? send_signup_req(rcv)-> databaseCh! val_chk(snd);
	:: serverCh? ack(rcv) -> userCh! ack(rcv);
	od
}

proctype Database(chan userCh, serverCh, databaseCh)
{
	bit rcv;
	do
	:: databaseCh? auth_send(rcv) -> serverCh! ack(rcv);
	:: databaseCh? send_usr_dt(rcv) -> serverCh! ack(rcv);
	:: databaseCh? val_chk(rcv) -> serverCh! ack(rcv);
	od
}

init
{
run User(user, server, database);
run Server(user, server, database);
run Database(user, server, database);
}
