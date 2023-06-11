// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

contract makeERC20{

    /*
    ERC20
    data + 9 methods + 2 Events
    1. name
    2. symbol
    3. decimals
    4. totalSupply
    5. transfer( to , amount ) -> emit Transfer
    6. transferFrom( from , to , amount ) -> emit Transfer
    7. approve( to/spender , amount ) : 부르는주체: 본인(owner/from)
    8. allownace
    9. balanceOf
    이벤트
    transfer(전송이 성공되었을때)
    approval
    */

    event Transfer( address indexed from , address indexed to , uint256 amount ) ;
    event Approval( address indexed owner , address indexed spender , uint256 amount ) ;
    /*
    Solidity에서 이벤트(Event)는 스마트 컨트랙트에서 특정 조건이 충족되었을 때 발생하는 로그를 기록하는 방법을 제공합니다.
    이벤트는 블록체인에 저장되므로, 누구나 이벤트를 트리거한 트랜잭션을 쉽게 추적할 수 있습니다.
    indexed 키워드는 이 매개변수를 이벤트의 로그에서 쉽게 검색할 수 있도록 인덱싱한다는 것을 의미합니다.
    */
     
    string public name = "TEST_ERC20" ;
    string public symbol = "TEC20" ;
    uint public decimals = 18 ;
    uint public totalSupply = 0 ; // mint 할 때마다 증가 , burn 할 때마다 감소

    // public : 배포하면 자동으로 함수로 보임.
    // 따로 구현을 안해도 됨.

    /*
    상정할 특수 상황( 특정 주기로 수량이 리셋 )
    1) contract 를 주기별로 배포 (T1_contract , T2_contract )
    mapping( address => uint ) balances ;
    2) 단일 contract로 주기별의 토큰을 관리
    mapping( uint => mapping( address => uint ) ) balanceOfTime ;
    */

    // transfer , balanceOf 

    /*
    balanceOf
    owner => amount : 특정 유저가 얼마만큼 가지고 있는지
    DH => 100       : 내가 100개
    swap => 10000   : swap 이 10000개
    */

    // 누가 얼마나 가지고 있냐
    mapping( address owner => uint amount ) balances ;
    // 누가 누구에게 얼마나 권한을 줬냐
    mapping ( address owner => mapping( address spender => uint amount ) ) public allowances ;

    function balanceOf( address owner ) public view returns( uint ){
        return balances[ owner ] ;
    }

    /*
    transfer
    실행 주체 : owner( from )

    */

    function transfer( address to , uint amount ) public returns( bool ){

        address from = msg.sender ;

        // 1. 에러케이스 생각

        // from 잔고보다 많으면 불가
        require( balances[ from ] >= amount ) ;

        /*
        2. 업데이트할것
        from( - )
        to ( + )
        */

        balances[ from ] -= amount ;
        balances[ to ] += amount ;
        // 오픈 재플린 erc20에서는 update를 따로 구현했음. 다 작성하고 한번 체크

        emit Transfer( from , to , amount ) ;
        return true ;

    }

    // 실행 주체 : spender( Uniswap Pair / Exchange ) 
    // 누가 누구에게 얼마나 허가해줬나
    // mapping ( address owner => mapping( address spender => uint amount ) ) public allowances ;
    function trasnferFrom( address from , address to , uint amount ) public returns( bool ) {

        address spender = msg.sender ;

        // 1. 에러케이스
        // _1. 잔고? from.balances >= amount
        require( balances[ from ] >= amount ) ;

        // _2. 권한? spender's allowance >= amount
        require( allowances[ from ][ spender ] >= amount ) ;

        // 2. data 업데이트
        // _1. 잔고변환
        balances[ from ] -= amount ;
        balances[ to ] += amount ;

        // _2. 권한변환
        allowances[ from ][ spender ] -= amount ;

        // 3. Event
        emit Transfer( from , to , amount ) ;

        // 4. return true
        return true ;

    }
    
    // approve
    // 실행주체 : owner 
    // owner + spender + amount

    function approve( address spender , uint amount ) public returns( bool ){

        address owner = msg.sender ;
        allowances[ owner ][ spender ] = amount ;
        // unapprove > approve( 0 )
        emit Approval( owner , spender , amount ) ;
        return true ;

    }

    // allowance

    function allowance( address owner , address spender ) public view returns( uint ){

        return allowances[ owner ][ spender ] ;

    }
    

}