

import UIKit

class StatementViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
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
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
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
    
    @IBOutlet weak var lblRecentTransactions: UILabel!
    
    
    var recentTransactions : [TransactionsStatementTransaction] = []
    
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
                
            }
        }
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

    @IBOutlet weak var tableView: UITableView!
    
    @IBAction func btn30Days(_ sender: Any) {
        
        LSBankAPI.statement(token: LoginViewController.token, days: 30, successHandler: refreshRecentTransactionsSuccess, failHandler: refreshRecentTransactionsFail)
        
    }
    
    @IBAction func btn60Days(_ sender: Any) {
        
        LSBankAPI.statement(token: LoginViewController.token, days: 60, successHandler: refreshRecentTransactionsSuccess, failHandler: refreshRecentTransactionsFail)
        
    }
    
    @IBAction func btn90Days(_ sender: Any) {
        
        LSBankAPI.statement(token: LoginViewController.token, days: 90, successHandler: refreshRecentTransactionsSuccess, failHandler: refreshRecentTransactionsFail)
        
    }
    
    private func initialize()
    {
        
        tableView.register(TransactionTableViewCell.nib(), forCellReuseIdentifier: TransactionTableViewCell.identifier)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.allowsSelection = false
        
    }
    
    
    @IBAction func btnBack(_ sender: Any) {
        
        navigationController?.popViewController(animated: true)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialize()
    }
    



}
