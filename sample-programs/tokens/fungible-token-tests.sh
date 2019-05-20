ALICE=SP2J6ZY48GV1EZ5V2V5RB9MP66SW86PYKKNRV9EJ7
BOB=S02J6ZY48GV1EZ5V2V5RB9MP66SW86PYKKPVKG2CE
OPERATOR=SZ2J6ZY48GV1EZ5V2V5RB9MP66SW86PYKKQ9H6DPR

# Check and initialize contract
blockstack-core local initialize test-tokens.sqlite3
blockstack-core local check sample-programs/tokens/fungible-token.scm test-tokens.sqlite3
blockstack-core local launch stx-fungible sample-programs/tokens/fungible-token.scm test-tokens.sqlite3

# Assertions
echo "-> ALICE's balance = 20 STX"
echo "(balance-of '$ALICE)" | blockstack-core local eval fungible-stx test-tokens.sqlite3
echo "-> BOB's balance = 10 STX"
echo "(balance-of '$BOB)" | blockstack-core local eval fungible-stx test-tokens.sqlite3

echo "-> BOB will send 10 STX to ALICE"
blockstack-core local execute test-tokens.sqlite3 fungible-stx transfer $BOB \'$ALICE 10

# Assertions
echo "-> ALICE's balance = 30 STX"
echo "(balance-of '$ALICE)" | blockstack-core local eval fungible-stx test-tokens.sqlite3
echo "-> BOB's balance = 0 STX"
echo "(balance-of '$BOB)" | blockstack-core local eval fungible-stx test-tokens.sqlite3

echo "-> BOB will send 1 STX to ALICE - should fail"
blockstack-core local execute test-tokens.sqlite3 fungible-stx transfer $BOB \'$ALICE 1

echo "-> ALICE will let ZOE spend 15 STX on her behalf"
blockstack-core local execute test-tokens.sqlite3 fungible-stx approve $ALICE \'$OPERATOR 15
echo "-> OPERATOR's allowance on ALICE's balance = 15 STX"
echo "(allowance-of '$OPERATOR '$ALICE)" | blockstack-core local eval fungible-stx test-tokens.sqlite3
echo "-> OPERATOR will transfer 15 STX from ALICE to BOB"
blockstack-core local execute test-tokens.sqlite3 fungible-stx transfer-from $OPERATOR \'$ALICE \'$BOB 15
echo "-> OPERATOR will transfer 1 STX from ALICE to BOB - should fail"
blockstack-core local execute test-tokens.sqlite3 fungible-stx transfer-from $OPERATOR \'$ALICE \'$BOB 1

# Assertions
echo "-> ALICE's balance = 15 STX"
echo "(balance-of '$ALICE)" | blockstack-core local eval fungible-stx test-tokens.sqlite3
echo "-> BOB's balance = 15 STX"
echo "(balance-of '$BOB)" | blockstack-core local eval fungible-stx test-tokens.sqlite3
echo "-> OPERATOR's allowance on ALICE's balance = 0 STX"
echo "(allowance-of '$OPERATOR '$ALICE)" | blockstack-core local eval fungible-stx test-tokens.sqlite3
