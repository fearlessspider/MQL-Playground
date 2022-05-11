    //+------------------------------------------------------------------------------------+
    // Initialisation Event Function
    //+------------------------------------------------------------------------------------+
    int OnInit()
    {
       // Check Licensing Restrictions
       if( boolRestrictOnInit() ) return( INIT_FAILED );

       // ...

       return( INIT_SUCCEEDED );  // Initialisation complete
    }
    //+------------------------------------------------------------------------------------+
    // Tick Event Function
    //+------------------------------------------------------------------------------------+
    void OnTick()
    {
       // Check Licensing Restrictions
       if( boolRestrictOnTick() ) return;
       
       /// ...
    }
    //+------------------------------------------------------------------------------------+
    // Function to Test Restrictions during Initialisation
    //+------------------------------------------------------------------------------------+
    bool boolRestrictOnInit()
    {
       boolRestrictions =
          boolRestrictExpiration     ||
          boolRestrictAccountNumber  ||
          boolRestrictAccountName    ||
          boolRestrictAccountServer  ||
          boolRestrictAccountCompany ||
          boolRestrictDemoAccount    ||
          boolRestrictSymbols;

       if( boolRestrictions )
       {
          boolRestrictionsUnverified = true;

          if( (bool) TerminalInfoInteger( TERMINAL_CONNECTED ) )
          {
             long longAccountNumber = AccountInfoInteger( ACCOUNT_LOGIN );
             if( longAccountNumber > 0 )
             {
                if( boolRestrictAccountNumber )
                   { if( longAccountNumber                        != longRestrictAccountNumber )
                      { return( boolRestrictAlert() ); } }
                if( boolRestrictAccountName )
                   { if( AccountInfoString( ACCOUNT_NAME )        != strRestrictAccountName    )
                      { return( boolRestrictAlert() ); } }
                if( boolRestrictAccountServer )
                   { if( AccountInfoString( ACCOUNT_SERVER )      != strRestrictAccountServer  )
                      { return( boolRestrictAlert() ); } }
                if( boolRestrictAccountCompany )
                   { if( AccountInfoString( ACCOUNT_COMPANY )     != strRestrictAccountCompany )
                      { return( boolRestrictAlert() ); } }
                if( boolRestrictDemoAccount )
                   { if( AccountInfoInteger( ACCOUNT_TRADE_MODE ) != ACCOUNT_TRADE_MODE_DEMO   )
                      { return( boolRestrictAlert() ); } }
                if( boolRestrictSymbols() )
                   { return( boolRestrictAlert() ); }

                boolRestrictionsUnverified = false;
             }
          }
       }
       return( false );
    }
    //+------------------------------------------------------------------------------------+
    // Function to Test Variations of Restricted Symbols
    //+------------------------------------------------------------------------------------+
    bool boolRestrictSymbols()
    {
       if( boolRestrictSymbols )
       {
          int intSymbolCount = ArraySize( strRestrictSymbols );
          if( intSymbolCount == 0 ) return( false );
          for( int i = 0; i < intSymbolCount; i++ )
          {
             if( StringFind( _Symbol, strRestrictSymbols[i] ) != WRONG_VALUE ) return( false );
             int
                intLen  = StringLen( strRestrictSymbols[i] ),
                intHalf = intLen / 2;
             string
                strLeft  = StringSubstr( strRestrictSymbols[i], 0, intHalf ),
                strRight = StringSubstr( strRestrictSymbols[i], intHalf, intLen - intHalf );
             if( ( StringFind( _Symbol, strLeft  ) != WRONG_VALUE ) &&
                 ( StringFind( _Symbol, strRight ) != WRONG_VALUE )    )
                return( false );
          }
          return( true );
       }
       return( false );
    }
    //+------------------------------------------------------------------------------------+
    // Function to Test Expiration during Tick Events
    //+------------------------------------------------------------------------------------+
    bool boolRestrictOnTick()
    {
       if( boolRestrictions )
       {
          if( boolRestrictionsUnverified )
             return( boolRestrictOnInit() );
          if( boolRestrictExpiration && ( TimeCurrent() >= dtRestrictExpiration ) )
             return( boolRestrictAlert()  );
       }
       return( false );
    }
    // Function to Alert User of Licensing Restrictions and Remove Code from Execution
    bool boolRestrictAlert()
    {
       if( boolRestrictAlert )
          MessageBox( strRestrictAlertMessage, strRestrictAlertCaption, MB_ICONERROR );
       ExpertRemove();
       return( true );
    }
    //+------------------------------------------------------------------------------------+
    //      Variables for Handling of Licensing Restrictions
    //+------------------------------------------------------------------------------------+
    bool
       boolRestrictExpiration     = false, // Set to true, to use an Experation Date
       boolRestrictAccountNumber  = false, // Set to true for Restricting by Account Number
       boolRestrictAccountName    = false, // Set to true for Restricting by Account Name
       boolRestrictAccountServer  = false, // Set to true for Restricting by Account Server
       boolRestrictAccountCompany = false, // Set to true for Restricting by Account Company
       boolRestrictDemoAccount    = false, // Set to true, to only allow Demo Accounts
       boolRestrictSymbols        = false, // Set to true, to only allow certain Symbols
       boolRestrictAlert          = true,  // Display Alert Message when Restrictions apply
       boolRestrictionsUnverified = false, // DO NOT CHANGE. For internal use only!
       boolRestrictions           = false; // DO NOT CHANGE. For internal use only!
    datetime
       dtRestrictExpiration       = D'2017.03.31';  // Restricted by Expration Date
    long
       longRestrictAccountNumber  = 123456789;      // Restricted by Account Number
    string
       strRestrictAccountName     = "Client Name",  // Restricted by Account Name
       strRestrictAccountServer   = "Server Name",  // Restricted by Account Server
       strRestrictAccountCompany  = "Company Name", // Restricted by Account Company
       strRestrictSymbols[]       = { "EURUSD", "GBPJPY", "NZDCAD" }, // Restricted Symbols
       strRestrictAlertCaption    = "Restrictions", // Alert Message Box Caption
       strRestrictAlertMessage    =
          "ATTENTION! Due to Licensing Restrictions, code execution has been blocked!";
          // Message to be used when Restrictions have been detected
    //+------------------------------------------------------------------------------------+
