//
//  IAPHelperX.swift
//  PaddleBallA52
//
//  Created by iMac 27 on 2015-09-14.
//  Copyright (c) 2015 Garth MacKenzie. All rights reserved.
//

import Foundation
import StoreKit

class IAPHelperX: NSObject, SKProductsRequestDelegate, SKPaymentTransactionObserver {
    
    let productIdentifiers: NSSet
    override init() {
        productIdentifiers = NSSet(objects: "com.garthmackenzie.PaddleBallA52.addCredits.10", "com.garthmackenzie.PaddleBallA52.addCredits.40", "com.garthmackenzie.PaddleBallA52.addCredits.70", "com.garthmackenzie.PaddleBallA52.addCredits.150", "com.garthmackenzie.PaddleBallA52.addCredits.350", "com.garthmackenzie.PaddleBallA52.addCredits.1000", "com.garthmackenzie.PaddleBallA52.addCredits.2500")
    }
    func requestProductsWithCompletionHandler(completionHandler:(Bool, [SKProduct]!) -> Void){
        self.completionHandler = completionHandler
        let productsRequest = SKProductsRequest(productIdentifiers: productIdentifiers as Set<NSObject>)
        productsRequest.delegate = self
        productsRequest.start()
    }
    var completionHandler: ((Bool, [SKProduct]!) -> Void)!
    func productsRequest(request: SKProductsRequest!, didReceiveResponse response: SKProductsResponse!) {
        println("product count \(response.products.count)")
        println("invalid product IDs \(response.invalidProductIdentifiers)")
        if response.products.count > 0 {
            var products: [SKProduct] = []
            for prod in response.products {
                if prod.isKindOfClass(SKProduct) {
                    products.append(prod as! SKProduct)
                }
            }
            completionHandler(true, products)
        }
    }
    func request(request: SKRequest!, didFailWithError error: NSError!) {
        println("please enable IAPS")
        completionHandler(false, nil)
    }
    func pay4Credits(credits: Int) {
        for product in list {
            var prodID = product.productIdentifier
            if (prodID.lastPathComponent == "\(credits)") {
                p = product
                buyProduct()
            }
        }
    }
    func addCredits(credits:Int) {
        Settings().availableCredits += credits
    }
    var list = [SKProduct]()
    var p = SKProduct()
    // iap.addCredits
    func buyProduct() {
        println("buy " + p.productIdentifier)
        var pay = SKPayment(product: p)
        SKPaymentQueue.defaultQueue().addTransactionObserver(self)
        SKPaymentQueue.defaultQueue().addPayment(pay as SKPayment)
    }
    //MARK: - SKPaymentTransactionObserver
    func paymentQueueRestoreCompletedTransactionsFinished(queue: SKPaymentQueue!) {
        println("transactions restored")
        var purchasedItemIDS = []
        for transaction in queue.transactions {
            var t: SKPaymentTransaction = transaction as! SKPaymentTransaction
            var prodID = t.payment.productIdentifier as String
            switch prodID {
            case "com.garthmackenzie.PaddleBallA52.addCredits.10":
                println("add 10 credits to account")
                addCredits(10)
            case "com.garthmackenzie.PaddleBallA52.addCredits.40":
                println("add 40 credits to account")
                addCredits(40)
            case "com.garthmackenzie.PaddleBallA52.addCredits.70":
                println("add 70 credits to account")
                addCredits(70)
            case "com.garthmackenzie.PaddleBallA52.addCredits.150":
                println("add 150 credits to account")
                addCredits(150)
            case "com.garthmackenzie.PaddleBallA52.addCredits.350":
                println("add 350 credits to account")
                addCredits(350)
            case "com.garthmackenzie.PaddleBallA52.addCredits.1000":
                println("add 1000 credits to account")
                addCredits(1000)
            case "com.garthmackenzie.PaddleBallA52.addCredits.2500":
                println("add 2500 credits to account")
                addCredits(2500)
            default:
                println("IAP not setup")
            }
        }
    }
    func paymentQueue(queue: SKPaymentQueue!, updatedTransactions transactions: [AnyObject]!) {
        println("add paymnet")
        for transaction:AnyObject in transactions {
            var trans = transaction as! SKPaymentTransaction
            println(trans.error)
            switch trans.transactionState {
            case .Purchased:
                println("buy, ok unlock iap here")
                println(p.productIdentifier)
                let prodID = p.productIdentifier as String
                switch prodID {
                case "com.garthmackenzie.PaddleBallA52.addCredits.10":
                    println("add 10 credits to account")
                    addCredits(10)
                case "com.garthmackenzie.PaddleBallA52.addCredits.40":
                    println("add 40 credits to account")
                    addCredits(40)
                case "com.garthmackenzie.PaddleBallA52.addCredits.70":
                    println("add 70 credits to account")
                    addCredits(70)
                case "com.garthmackenzie.PaddleBallA52.addCredits.150":
                    println("add 150 credits to account")
                    addCredits(150)
                case "com.garthmackenzie.PaddleBallA52.addCredits.350":
                    println("add 350 credits to account")
                    addCredits(350)
                case "com.garthmackenzie.PaddleBallA52.addCredits.1000":
                    println("add 1000 credits to account")
                    addCredits(1000)
                case "com.garthmackenzie.PaddleBallA52.addCredits.2500":
                    println("add 2500 credits to account")
                    addCredits(2500)
                default:
                    println("IAP not setup")
                }
                queue.finishTransaction(trans)
                break;
            case .Failed:
                println("buy error")
                queue.finishTransaction(trans)
                break;
            default:
                println("default")
                break;
            }
        }
    }
    func finishTransaction(trans:SKPaymentTransaction) {
        println("finishTransaction")
        SKPaymentQueue.defaultQueue().finishTransaction(trans)
    }
    func paymentQueue(queue: SKPaymentQueue!, removedTransactions transactions: [AnyObject]!) {
        println("removedTransactions");
    }

}