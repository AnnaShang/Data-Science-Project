/*  
    Instant-runoff Voting Simulator
    
    Rules for IRV (From Wikipedia):
    Instead of voting only for a single candidate, voters in IRV 
    elections can rank the candidates in order of preference. 
    Ballots are initially counted for each elector's top choice. 
    If a candidate secures more than half of these votes, that 
    candidate wins. Otherwise, the candidate in last place is 
    eliminated and removed from consideration. The top remaining 
    choices on all the ballots are then counted again. This process 
    repeats until one candidate is the top remaining choice of a 
    majority of the voters. When the field is reduced to two, 
    it has become an "instant runoff" that allows a comparison 
    of the top two candidates head-to-head.

    Assumption: 
    No candidates get more than majority of votes in any round.
    The winner is only generated in the last round from the last two
    candidates.

    Author: 
    Ruoxi Shang    
*/

/*Simulate Round 1*/
CREATE TABLE ROUND_1 AS
    SELECT COUNT(id) as Vote,X1 as Name
    FROM votes 
    GROUP BY X1
    ORDER BY Vote;

CREATE TABLE LOOSER_1 As
    SELECT Name from ROUND_1
    Limit 1;

/*Simulate Round 2*/    
CREATE TABLE ROUND_2 AS
    SELECT
        CASE
            WHEN X1 = (SELECT Name FROM LOOSER_1)
            THEN X2
            ELSE X1 
        END as Name, Count(*) as Vote
    FROM votes
    GROUP BY Name
    ORDER BY Vote;

CREATE TABLE LOOSER_2 As
    SELECT Name from ROUND_2
    Limit 1;

/*Simulate Round 3*/
CREATE TABLE ROUND_3 AS
    SELECT
        CASE
            WHEN X1 = (SELECT Name FROM LOOSER_1) OR X1 = (SELECT Name FROM LOOSER_2)
            THEN 
                CASE
                    WHEN X2 = (SELECT Name FROM LOOSER_1) OR X2 = (SELECT Name FROM LOOSER_2)
                    THEN X3
                    ELSE X2            
                END
            ELSE X1
        END as Name, Count(*) as Vote
    FROM votes
    GROUP BY Name
    ORDER BY Vote;

CREATE TABLE LOOSER_3 as
    SELECT Name FROM ROUND_3
    LIMIT 1;

/*Simulate Round 4*/
CREATE TABLE ROUND_4 AS
    SELECT
        CASE
            WHEN X1 = (SELECT Name FROM LOOSER_1) OR X1 = (SELECT Name FROM LOOSER_2) OR X1 = (SELECT Name FROM LOOSER_3)
            THEN 
                CASE
                    WHEN X2 = (SELECT Name FROM LOOSER_1) OR X2 = (SELECT Name FROM LOOSER_2) OR X2 = (SELECT Name FROM LOOSER_3)
                    THEN
                        CASE
                            WHEN X3 = (SELECT Name FROM LOOSER_1) OR X3 = (SELECT Name FROM LOOSER_2) OR X3 = (SELECT Name FROM LOOSER_3)
                            THEN X4
                            ELSE X3
                        END
                    ELSE X2            
                END
            ELSE X1
        END as Name, Count(*) as Vote
    FROM votes
    GROUP BY Name
    ORDER BY Vote DESC;

/*Display final result of the winner and marginal difference of votes between the last two candidates*/
SELECT Name as Winner, ((SELECT MAX(Vote) FROM ROUND_4)- (SELECT MIN(Vote) FROM ROUND_4))||' votes' as Margin 
FROM ROUND_4
WHERE Vote = (SELECT MAX(Vote) FROM ROUND_4);
