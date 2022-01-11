//
//  MainViewController.swift
//  IOS-FinalProject-LSBank
//
//  Created by user203175 on 10/19/21.
//

import UIKit

class MainViewController: UIViewController, BalanceRefresh, UITableViewDelegate, UITableViewDataSource {
    
    var context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var recentTransactions : [TransactionsStatementTransaction] = []
    
    var refereshControl = UIRefreshControl()
    
    @IBOutlet weak var vBtnWithdraw : UIView!
    @IBOutlet weak var vBtnDeposit : UIView!
    @IBOutlet weak var vBtnTransfer : UIView!
    
    @IBOutlet weak var lblUsername : UILabel!
    @IBOutlet weak var lblBalance : UILabel!
    
    @IBOutlet weak var btnRefreshBalance : UIButton!
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var lblRecentTransactions: UILabel!
        
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        initialize()
        
        lblUsername.text = "Hi \(LoginViewController.account!.firstName)"
        
        refreshBalance()
    }
    
    private func initialize()
    {
        customizeView()
        
//        generateMockData()
        
        tableView.register(TransactionTableViewCell.nib(), forCellReuseIdentifier: TransactionTableViewCell.identifier)
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.allowsSelection = false
        
        refereshControl.addTarget(self, action: #selector(tableRefreshControl), for: .valueChanged)
        
        tableView.addSubview(refereshControl)
    }
    
    @objc func tableRefreshControl(send: UIRefreshControl)
    {
        DispatchQueue.main.async
        {
            self.refreshBalance()
            self.refereshControl.endRefreshing()
        }
    }
    
    private func customizeView() {
        vBtnWithdraw.setLayerCornerRadius(MyAppDefaults.LayerCornerRadius.button)
        vBtnDeposit.setLayerCornerRadius(MyAppDefaults.LayerCornerRadius.button)
        vBtnTransfer.setLayerCornerRadius(MyAppDefaults.LayerCornerRadius.button)
    }
    
    
    @IBAction func btnLogOff(_ sender: Any) {
        
        let btnYes = Dialog.DialogButton(title: "Yes", style: .default, handler: {action in
            self.navigationController?.popViewController(animated: true)
        })
        let btnNo = Dialog.DialogButton(title: "No", style: .destructive, handler: nil)
        
        Dialog.show(view: self, title: "Login off", message: "\(LoginViewController.account!.firstName), are you sure you want to leave?", style: .actionSheet, completion: nil, presentAnimated: true, buttons: btnYes, btnNo)
        
    }
    
    
    
    func refreshBalanceSuccess(httpStatusCode : Int, response : [String:Any] ){
        
        DispatchQueue.main.async {
            self.btnRefreshBalance.isEnabled = true
            self.lblBalance.text = "?"
        }
        
        if httpStatusCode == 200 {
            
            if let accountBalance = AccountsBalance.decode(json: response){
                
                DispatchQueue.main.async {
                    self.lblBalance.text = "CAD$ " + accountBalance.balance.formatAsCurrency()
                }
                
            }
        } else {
            DispatchQueue.main.async {
                Toast.show(view: self, title: "Something went wrong!", message: "Error parsing data received from server! Try again!")
            }
        }
        
    }
    
    
    func refreshBalanceFail( httpStatusCode : Int, message : String ){
        
        DispatchQueue.main.async {
            self.lblBalance.text = ""
            self.btnRefreshBalance.isEnabled = true
            Toast.show(view: self, title: "Ooops!", message: message)
        }
        
    }
    
    
    
    func refreshBalance() {
        
        lblBalance.text = "wait..."
        
        LSBankAPI.accountBalance(token: LoginViewController.token, successHandler: refreshBalanceSuccess, failHandler: refreshBalanceFail)
        
        // refresh the tableview with recent transactions
        refreshRecentTransactions()
        
    }
    
    // 2021 - 11 - 29
    func refreshRecentTransactionsSuccess (httpStatusCode : Int, response : [String:Any] )
    {
        DispatchQueue.main.async
        {
        }
        
        if httpStatusCode == 200
        {
            if let transactions = TransactionStatement.decode(json: response)
            {
                DispatchQueue.main.async
                {
                    self.recentTransactions = transactions.statement
                    self.tableView.reloadData()
                }
                
            }        }
        else
        {
            DispatchQueue.main.async
            {
                Toast.show(view: self, title: "Something went wrong!", message: "Error parsing data received from server! Try again!")
            }
        }
        
    }
    
    func refreshRecentTransactionsFail ( httpStatusCode : Int, message : String ){
        
        DispatchQueue.main.async
        {
            Toast.show(view: self, title: "Ooops!", message: message)
        }
        
    }
    
    func refreshRecentTransactions ()
    {
        LSBankAPI.statement(token: LoginViewController.token, days: 30, successHandler: refreshRecentTransactionsSuccess, failHandler: refreshRecentTransactionsFail)
    }
    
    @IBAction func btnRefreshBalanceTouchUp(_ sender : Any? ) {
        
        btnRefreshBalance.isEnabled = false
        refreshBalance()
        
    }
    
    @IBAction func btnPayeeTouchUp(_ sender : Any? ) {
        
        performSegue(withIdentifier: Segue.toPayeesView, sender: nil)
        
    }
    
    @IBAction func btnSendMoneyTouchUp(_ sender : Any? ){
        
        if Payee.all(context: self.context).count == 0 {
            Toast.ok(view: self, title: "No payees", message: "Please, set your payees list before sending money!")
            return
        }
        
        
        performSegue(withIdentifier: Segue.toSendMoneyView, sender: nil)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == Segue.toSendMoneyView {
            
            (segue.destination as! SendMoneyViewController).payeeList = Payee.allByFirstName(context: self.context)
            (segue.destination as! SendMoneyViewController).delegate = self
            
            
        }
        
    }
    
    func balanceRefresh() {
        // BalanceRefresh protocol stub
        self.refreshBalance()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection: Int) -> Int {
        if self.recentTransactions.count == 0
        {
            lblRecentTransactions.text = "No recent Transactions"
        }
        else if (recentTransactions.count == 1)
        {
            self.lblRecentTransactions.text = "\(recentTransactions.count) recent transaction"
        }
        else if (recentTransactions.count > 1)
        {
            lblRecentTransactions.text = "\(recentTransactions.count) recent transactions"
        }
        
        // return 10
        return recentTransactions.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: TransactionTableViewCell.identifier, for: indexPath) as!TransactionTableViewCell
        
        let transaction = recentTransactions[recentTransactions.count - 1 - indexPath.row]
        
        var accountHolder = ""
        var credit = true
        
        if transaction.toAccount!.accountId .contains(LoginViewController.account!.accountId)
        {
            credit = true
            accountHolder = "\(transaction.fromAccount!.firstName.uppercased()) \(transaction.fromAccount!.lastName.uppercased())"
        }
        else
        {
            credit = false
            accountHolder = "\(transaction.toAccount!.firstName.uppercased()) \(transaction.toAccount!.lastName.uppercased())"
        }
        
        cell.setCellContent(holder: accountHolder, dateAndTime: transaction.dateTime, amount: transaction.amount, credit: credit, message: transaction.message)
        
        
        // cell.setCellContent(holder: "Daniel Carvalho", dateAndTime: "yyyy-mm-dd 00:00:00", amount: 200, credit: true, message: "Thanks!")
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexpath: IndexPath) -> CGFloat
    {
        
        let transaction = recentTransactions[recentTransactions.count - 1 - indexpath.row]
        
        if transaction.message.count == 0
        {
            return 204
        }
        else
        {
            return 204
        }
    }

    
}
